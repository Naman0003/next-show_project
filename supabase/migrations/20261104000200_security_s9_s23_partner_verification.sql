-- Security fixes S23 + S9 (see security_fixes.md). Idempotent.

---------------------------------------------------------
-- S23: admin verification was bypassable.
-- Users may self-upgrade to role 'partner' (unverified by design), but the venue,
-- showtime and invite policies only checked the role, so an unverified self-made
-- "partner" could create venues and publish showtimes with arbitrary booking_url.
-- is_partner() = admin OR (partner AND is_verified).
---------------------------------------------------------
drop policy if exists "Partners can manage their own venues" on public.venues;
create policy "Partners can manage their own venues"
  on public.venues for all
  using (auth.uid() = owner_id and public.is_partner())
  with check (auth.uid() = owner_id and public.is_partner());

drop policy if exists "Partners can manage showtimes for their venues" on public.showtimes;
create policy "Partners can manage showtimes for their venues"
  on public.showtimes for all
  using (public.is_partner() and exists (
    select 1 from public.venues v where v.id = showtimes.venue_id and v.owner_id = auth.uid()))
  with check (public.is_partner() and exists (
    select 1 from public.venues v where v.id = showtimes.venue_id and v.owner_id = auth.uid()));

drop policy if exists "Venue owners can manage invites" on public.organizer_invites;
create policy "Venue owners can manage invites"
  on public.organizer_invites for all
  using (public.is_partner() and exists (
    select 1 from public.venues v where v.id = organizer_invites.venue_id and v.owner_id = auth.uid()))
  with check (public.is_partner() and exists (
    select 1 from public.venues v where v.id = organizer_invites.venue_id and v.owner_id = auth.uid()));

---------------------------------------------------------
-- S9: click analytics. The old policy let ANY partner/admin role (verified or not)
-- read every click incl. user_id. Now: admins read all; verified partners read only
-- clicks on showtimes at venues they own.
---------------------------------------------------------
drop policy if exists "Admins and Partners can read clicks" on public.outbound_clicks;
create policy "Partners read clicks on their venues"
  on public.outbound_clicks for select
  using (
    public.is_admin()
    or (public.is_partner() and exists (
      select 1 from public.showtimes s join public.venues v on v.id = s.venue_id
      where s.id = outbound_clicks.showtime_id and v.owner_id = auth.uid()))
  );
