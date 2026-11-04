-- Account deletion with a 14-day grace period (see supabase/functions/delete-account and
-- supabase/functions/account-deletion-maintenance). Idempotent.
--
-- Deleting an account only adds a row here. The user can sign in and restore until
-- scheduled_for; the hourly maintenance job then emails a reminder 24h before and finally
-- removes the auth user (profiles, tickets etc. cascade from auth.users).

create table if not exists public.account_deletions (
    user_id uuid primary key references auth.users(id) on delete cascade,
    email text not null,                                    -- kept for the reminder mail
    requested_at timestamptz not null default now(),
    scheduled_for timestamptz not null default now() + interval '14 days',
    reminder_sent_at timestamptz,
    last_error text                                         -- why the last purge attempt failed
);

create index if not exists idx_account_deletions_scheduled on public.account_deletions (scheduled_for);

alter table public.account_deletions enable row level security;

-- Users can see their own pending deletion (the app asks "restore your account?").
-- Nobody writes through the API: rows are created by the delete-account edge function
-- (service role) and removed by restore_account() below.
revoke all on table public.account_deletions from anon, authenticated;
grant select on table public.account_deletions to authenticated;

drop policy if exists "Users read own pending deletion" on public.account_deletions;
create policy "Users read own pending deletion"
  on public.account_deletions for select to authenticated
  using (user_id = auth.uid());

-- Cancels the caller's own pending deletion. Returns true if there was one.
create or replace function public.restore_account()
returns boolean as $$
declare n integer;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;
  delete from public.account_deletions where user_id = auth.uid();
  get diagnostics n = row_count;
  return n > 0;
end;
$$ language plpgsql security definer set search_path = public;

revoke execute on function public.restore_account() from public, anon;
grant execute on function public.restore_account() to authenticated;
