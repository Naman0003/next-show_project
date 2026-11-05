-- Event organizer + partner showtimes only for their own events. Idempotent.
--
-- events.organizer_name says who runs an event. The database sets it, so a client can't put a
-- real venue's name on its listing:
--   partner/admin events  -> the creator's profile name (email when no name is set)
--   crawled events        -> the organizer named on the source page, else 'Fetched from the internet'
-- Partners can only add showtimes for events they created (before: any event, e.g. someone
-- else's or a crawled one, at their venue).

alter table public.events add column if not exists organizer_name text;

create or replace function public.guard_event_write()
returns trigger as $$
begin
  if tg_op = 'INSERT' then
    if auth.uid() is not null then
      -- shortcut: the name is copied at creation; renaming a profile later doesn't update old events.
      new.organizer_name = (select coalesce(nullif(trim(p.full_name), ''), p.email)
                            from public.profiles p where p.id = auth.uid());
    elsif new.created_by is null then
      new.organizer_name = coalesce(nullif(trim(new.organizer_name), ''),
                                    nullif(trim(new.metadata->>'organizer'), ''),
                                    'Fetched from the internet');
    end if;
  elsif auth.uid() is not null and not public.is_admin() then
    new.organizer_name = old.organizer_name;
  end if;

  -- Service role (edge functions, auth.uid() is null) and admins write the rest freely.
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

-- Backfill (runs as the migration role, so the trigger leaves organizer_name alone on update).
update public.events e
set organizer_name = coalesce(nullif(trim(p.full_name), ''), p.email)
from public.profiles p
where e.created_by = p.id and e.organizer_name is null;

update public.events
set organizer_name = coalesce(nullif(trim(metadata->>'organizer'), ''), 'Fetched from the internet')
where created_by is null and organizer_name is null;

-- Same view as 20261106000000, plus organizer_name at the end.
create or replace view public.v_listings with (security_invoker = on) as
 SELECT s.id AS showtime_id,
    s.start_time,
    s.end_time,
    s.price,
    s.attributes AS showtime_attributes,
    s.booking_url,
    e.id AS event_id,
    e.category,
    e.title AS event_title,
    e.description AS event_description,
    e.image_url,
    e.duration_minutes,
    e.metadata AS event_metadata,
    e.is_verified AS event_is_verified,
    v.id AS venue_id,
    v.name AS venue_name,
    v.venue_type,
    v.address AS venue_address,
    public.st_x((v.location)::public.geometry) AS longitude,
    public.st_y((v.location)::public.geometry) AS latitude,
    e.organizer_name
   FROM ((public.showtimes s
     JOIN public.events e ON ((s.event_id = e.id)))
     JOIN public.venues v ON ((s.venue_id = v.id)))
  WHERE coalesce(s.end_time, s.start_time + interval '2 hours') >= now()
    AND s.status = 'published'::public.event_status
    AND e.status = 'published'::public.event_status
    AND v.is_active = true
  ORDER BY s.start_time;

-- Showtimes: a partner's new or changed showtime must be at their venue AND for their own event.
drop policy if exists "Partners can manage showtimes for their venues" on public.showtimes;
create policy "Partners can manage showtimes for their venues"
  on public.showtimes to authenticated
  using (public.is_partner() and exists (
    select 1 from public.venues v where v.id = showtimes.venue_id and v.owner_id = auth.uid()))
  with check (public.is_partner()
    and exists (select 1 from public.venues v where v.id = showtimes.venue_id and v.owner_id = auth.uid())
    and exists (select 1 from public.events e where e.id = showtimes.event_id and e.created_by = auth.uid()));
