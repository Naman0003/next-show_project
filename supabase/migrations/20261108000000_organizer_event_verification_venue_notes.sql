-- Organizer app fixes (fixes.md: S3, S10). Idempotent.
--
-- S3: a partner could mark an event verified by sending is_verified = true with any tmdb_id.
--     Now clients can never set the flag; the `tmdb` edge function sets it (service role) after
--     checking the movie against TMDB. Changing a TMDB-sourced field later drops the flag again.
-- S10: venues.partner_notes was readable by every signed-in user. Notes move to venue_notes,
--     which only the venue's (verified) owner and admins can read or write.

-- S3 -----------------------------------------------------------------------------------------
create or replace function public.guard_event_write()
returns trigger as $$
begin
  -- Service role (edge functions, auth.uid() is null) and admins write freely.
  if auth.uid() is null or public.is_admin() then
    return new;
  end if;

  if tg_op = 'INSERT' then
    new.is_verified = false;
  else
    new.created_by = old.created_by;
    if new.title is distinct from old.title
       or new.description is distinct from old.description
       or new.image_url is distinct from old.image_url
       or new.duration_minutes is distinct from old.duration_minutes
       or new.category is distinct from old.category
       or new.external_ids is distinct from old.external_ids then
      new.is_verified = false;
    else
      new.is_verified = old.is_verified;
    end if;
  end if;
  return new;
end;
$$ language plpgsql security definer set search_path = public;
-- (trigger guard_event_write from 20261104000100 already points at this function)

-- S10 ----------------------------------------------------------------------------------------
create table if not exists public.venue_notes (
    venue_id uuid primary key references public.venues(id) on delete cascade,
    notes text not null,
    updated_at timestamptz not null default now()
);

alter table public.venue_notes enable row level security;
revoke all on table public.venue_notes from anon;
grant select, insert, update, delete on table public.venue_notes to authenticated;

drop policy if exists "Venue owners and admins manage notes" on public.venue_notes;
create policy "Venue owners and admins manage notes"
  on public.venue_notes for all to authenticated
  using (public.is_admin() or (public.is_partner() and exists (
    select 1 from public.venues v where v.id = venue_notes.venue_id and v.owner_id = auth.uid())))
  with check (public.is_admin() or (public.is_partner() and exists (
    select 1 from public.venues v where v.id = venue_notes.venue_id and v.owner_id = auth.uid())));

-- Move existing notes of partner venues, then drop the column. Unowned venues only carry the
-- fetcher's "Auto-created by ingest-events" note, which owner_id is null already says.
do $$
begin
  if exists (select 1 from information_schema.columns
             where table_schema = 'public' and table_name = 'venues' and column_name = 'partner_notes') then
    insert into public.venue_notes (venue_id, notes)
    select id, partner_notes from public.venues
    where owner_id is not null and nullif(trim(partner_notes), '') is not null
    on conflict (venue_id) do nothing;
    alter table public.venues drop column partner_notes;
  end if;
end $$;
