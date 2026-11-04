-- Listings and venue privacy fixes (fixes.md: S11, A3, S10, S6). Idempotent.
--
-- S11: v_listings ran with its owner's rights, so table RLS did not apply, and it ignored
--      events.status (a cancelled event still showed if its showtime was published).
-- A3:  v_listings hid a show the minute it started. It now stays listed until it ends
--      (or 2 hours after the start when there is no end time).
-- S10: anonymous users could read venues.owner_id and venues.partner_notes.
-- S6:  booking links can only be https.

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
    public.st_y((v.location)::public.geometry) AS latitude
   FROM ((public.showtimes s
     JOIN public.events e ON ((s.event_id = e.id)))
     JOIN public.venues v ON ((s.venue_id = v.id)))
  WHERE coalesce(s.end_time, s.start_time + interval '2 hours') >= now()
    AND s.status = 'published'::public.event_status
    AND e.status = 'published'::public.event_status
    AND v.is_active = true
  ORDER BY s.start_time;

-- S10: column grants instead of a table grant for anon. Signed-in partners and admins keep
-- full access (the organizer and admin apps read these columns); the user app never reads
-- venues directly, only through v_listings.
-- Policies are checked with the caller's column rights, so a policy that reads venues.owner_id
-- would make every anon read of showtimes or v_listings fail. These four only ever match a
-- verified partner (is_partner()), so scoping them to signed-in users changes nothing else.
alter policy "Partners can manage their own venues" on public.venues to authenticated;
alter policy "Partners can manage showtimes for their venues" on public.showtimes to authenticated;
alter policy "Partners read clicks on their venues" on public.outbound_clicks to authenticated;
alter policy "Venue owners can manage invites" on public.organizer_invites to authenticated;

revoke select on table public.venues from anon;
grant select (id, created_at, updated_at, name, venue_type, address, location, website_url,
              image_url, is_active)
  on table public.venues to anon;

-- S6: NOT VALID enforces the rule on every new or changed row without re-checking old ones
-- (all 50 rows on production were https on 2026-11-04).
alter table public.showtimes drop constraint if exists showtimes_booking_url_https;
alter table public.showtimes add constraint showtimes_booking_url_https
  check (booking_url is null or booking_url ~* '^https://[^/]') not valid;
