-- S9: booking clicks go through a rate-limited function instead of direct inserts. Idempotent.
--
-- Before: anyone with the anon key could insert unlimited outbound_clicks rows (and pick
-- user_id = null), inflating the analytics venues see. Now clients can only call
-- record_click(showtime_id), which takes user_id from the session and allows CLICK_LIMIT clicks
-- per caller per 10-minute window. A caller is the signed-in user, or for guests the client IP.

create table if not exists public.click_rate_limits (
    bucket_key text not null,               -- 'u:<user id>' or 'ip:<md5 of client ip>'
    window_start timestamptz not null,      -- start of the 10-minute window
    hits integer not null default 1,
    primary key (bucket_key, window_start)
);
create index if not exists idx_click_rate_limits_window on public.click_rate_limits (window_start);

-- Internal bookkeeping only: no client access at all.
alter table public.click_rate_limits enable row level security;
revoke all on table public.click_rate_limits from anon, authenticated;

create or replace function public.record_click(p_showtime_id uuid)
returns boolean as $$
declare
  -- 20 clicks per 10 minutes per caller: far above a real person, low enough to make spam pointless.
  click_limit constant integer := 20;
  headers json := coalesce(nullif(current_setting('request.headers', true), ''), '{}')::json;
  -- cf-connecting-ip is set by Cloudflare in front of the Supabase API and can't be forged
  -- through it; the others are fallbacks.
  client_ip text := coalesce(
    nullif(headers->>'cf-connecting-ip', ''),
    nullif(headers->>'x-real-ip', ''),
    nullif(trim(split_part(headers->>'x-forwarded-for', ',', 1)), ''),
    'unknown');
  bucket text := case when auth.uid() is not null then 'u:' || auth.uid()::text
                      else 'ip:' || md5(client_ip) end;
  win timestamptz := to_timestamp(floor(extract(epoch from now()) / 600) * 600);
  n integer;
begin
  if p_showtime_id is null
     or not exists (select 1 from public.showtimes where id = p_showtime_id and status = 'published') then
    return false;
  end if;

  insert into public.click_rate_limits as r (bucket_key, window_start) values (bucket, win)
  on conflict (bucket_key, window_start) do update set hits = r.hits + 1
  returning hits into n;
  if n > click_limit then
    return false;
  end if;

  insert into public.outbound_clicks (showtime_id, user_id) values (p_showtime_id, auth.uid());

  -- shortcut: trims old windows on every click; move to a pg_cron job if clicks reach many per second.
  delete from public.click_rate_limits where window_start < now() - interval '1 hour';
  return true;
end;
$$ language plpgsql security definer set search_path = public;

revoke execute on function public.record_click(uuid) from public;
grant execute on function public.record_click(uuid) to anon, authenticated;

-- No more direct inserts from clients.
drop policy if exists "Users can insert their own clicks" on public.outbound_clicks;
revoke insert on table public.outbound_clicks from anon, authenticated;
