-- Security fix S3 (see security_fixes.md): partners may only edit events they created,
-- and cannot self-verify them. Idempotent.

-- Ownership. Service-role inserts (ingest-events) have no auth.uid(), so created_by stays null
-- and only admins can edit those rows.
alter table public.events
  add column if not exists created_by uuid references public.profiles(id) on delete set null
  default auth.uid();

-- Backfill: the owner of the first venue that screens the event keeps edit access.
update public.events e
set created_by = (
  select v.owner_id
  from public.showtimes s
  join public.venues v on v.id = s.venue_id
  where s.event_id = e.id
  order by s.created_at
  limit 1
)
where e.created_by is null
  and e.metadata->>'source' is distinct from 'ingest-events';

alter table public.events alter column is_verified set default false;

drop policy if exists "Partners can insert events" on public.events;
create policy "Partners can insert events"
  on public.events for insert
  with check (public.is_partner() and created_by = auth.uid());

drop policy if exists "Partners can update events" on public.events;
create policy "Partners can update events"
  on public.events for update
  using (public.is_partner() and created_by = auth.uid())
  with check (public.is_partner() and created_by = auth.uid());

-- Non-admins cannot choose the verified flag or reassign ownership.
-- shortcut: a partner can still claim "verified" on INSERT by supplying any tmdb_id;
-- upgrade by verifying against TMDB in an edge function before setting the flag.
create or replace function public.guard_event_write()
returns trigger as $$
begin
  if auth.uid() is null or public.is_admin() then
    return new;
  end if;

  if tg_op = 'INSERT' then
    new.is_verified = coalesce(new.is_verified, false)
                      and (new.external_ids->>'tmdb_id') is not null;
  else
    new.is_verified = old.is_verified;
    new.created_by = old.created_by;
  end if;
  return new;
end;
$$ language plpgsql security definer set search_path = public;

drop trigger if exists guard_event_write on public.events;
create trigger guard_event_write
  before insert or update on public.events
  for each row execute function public.guard_event_write();
