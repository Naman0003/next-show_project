-- Next Show: schema of the Supabase `public` schema (project waqyoiheasnmtaqqayma).
--
-- GENERATED from the live production schema (pulled 2026-11-04) with the security
-- migrations applied: supabase/migrations/20261104000000_security_s1_s2_s4_s12.sql and
-- supabase/migrations/20261104000100_security_s3_events.sql and
-- supabase/migrations/20261104000200_security_s9_s23_partner_verification.sql and 20261105000000_account_deletions.sql.
-- See security_fixes.md.
--
-- Fresh-project bootstrap ONLY. Existing projects evolve through supabase/migrations/;
-- never re-run this on a live database. Regenerate after schema changes instead of hand-editing:
--   supabase db dump --remote -s public -f <file>     (pre-fix baseline lives in supabase/tests/)
-- Tests: supabase/tests/README.md.

create extension if not exists postgis;

--
--
\restrict NlsT1beFUKOqVC3bRywdSygzd700WBoht1n6avj3QR28ufi6NRsn2Yx0i4RKVEu
SET transaction_timeout = 0;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--
--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--
--
-- Name: event_status; Type: TYPE; Schema: public; Owner: -
--
CREATE TYPE public.event_status AS ENUM (
    'draft',
    'published',
    'cancelled'
);
--
-- Name: user_role; Type: TYPE; Schema: public; Owner: -
--
CREATE TYPE public.user_role AS ENUM (
    'user',
    'partner',
    'admin'
);
--
-- Name: accept_organizer_invite(text); Type: FUNCTION; Schema: public; Owner: -
--
CREATE FUNCTION public.accept_organizer_invite(invite_token text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
declare
  v_invite record;
  v_email text := lower(coalesce(auth.jwt() ->> 'email', ''));
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;
  select * into v_invite from public.organizer_invites
  where token = invite_token
    and accepted_at is null
    and (expires_at is null or expires_at > now())
    and lower(email) = v_email
  for update;
  if v_invite.id is null then
    raise exception 'Invalid or expired invite token';
  end if;
  update public.profiles set role = 'partner'
  where id = auth.uid() and role = 'user';
  if v_invite.role = 'owner' then
    update public.venues set owner_id = auth.uid() where id = v_invite.venue_id;
  end if;
  update public.organizer_invites set accepted_at = now() where id = v_invite.id;
end;
$$;
--
-- Name: check_profile_update(); Type: FUNCTION; Schema: public; Owner: -
--
CREATE FUNCTION public.check_profile_update() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
begin
  -- Direct DB / service-role access (no JWT) and admins are unrestricted.
  if auth.uid() is null or public.is_admin() then
    return new;
  end if;
  new.email = old.email;
  new.is_verified = old.is_verified;
  -- Users may self-upgrade to (unverified) partner; every other role change is reverted.
  if old.role is distinct from new.role
     and not (old.role = 'user'::user_role and new.role = 'partner'::user_role) then
    new.role = old.role;
  end if;
  return new;
end;
$$;
--
-- Name: guard_event_write(); Type: FUNCTION; Schema: public; Owner: -
--
CREATE FUNCTION public.guard_event_write() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
begin
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
$$;
--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: -
--
CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
begin
  insert into public.profiles (id, email, full_name, role)
  values (new.id, new.email, new.raw_user_meta_data->>'full_name', 'user'::user_role)
  on conflict (id) do nothing;
  return new;
end;
$$;
--
-- Name: handle_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--
CREATE FUNCTION public.handle_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  new.updated_at = now();
  return new;
end;
$$;
--
-- Name: is_admin(); Type: FUNCTION; Schema: public; Owner: -
--
CREATE FUNCTION public.is_admin() RETURNS boolean
    LANGUAGE sql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  select exists (
    select 1 from public.profiles 
    where id = auth.uid() and role = 'admin'
  );
$$;
--
-- Name: is_partner(); Type: FUNCTION; Schema: public; Owner: -
--
CREATE FUNCTION public.is_partner() RETURNS boolean
    LANGUAGE sql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = auth.uid() 
      AND (role = 'admin' OR (role = 'partner' AND is_verified = true))
  );
$$;
--
-- Name: sync_profile_email(); Type: FUNCTION; Schema: public; Owner: -
--
CREATE FUNCTION public.sync_profile_email() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
begin
  update public.profiles set email = new.email where id = new.id;
  return new;
end;
$$;
SET default_tablespace = '';
SET default_table_access_method = heap;
--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--
CREATE TABLE public.events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    category text NOT NULL,
    title text NOT NULL,
    description text,
    image_url text,
    duration_minutes integer,
    external_ids jsonb DEFAULT '{}'::jsonb,
    metadata jsonb DEFAULT '{}'::jsonb,
    status public.event_status DEFAULT 'published'::public.event_status,
    is_verified boolean DEFAULT false NOT NULL,
    created_by uuid DEFAULT auth.uid()
);
--
-- Name: ingestion_sources; Type: TABLE; Schema: public; Owner: -
--
CREATE TABLE public.ingestion_sources (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    name text NOT NULL,
    url text NOT NULL,
    kind text NOT NULL,
    city text DEFAULT 'Berlin'::text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    last_run_at timestamp with time zone,
    last_status text,
    CONSTRAINT ingestion_sources_kind_check CHECK ((kind = ANY (ARRAY['rss'::text, 'html'::text])))
);
--
-- Name: organizer_invites; Type: TABLE; Schema: public; Owner: -
--
CREATE TABLE public.organizer_invites (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    venue_id uuid NOT NULL,
    invited_by uuid,
    email text NOT NULL,
    role text DEFAULT 'editor'::text NOT NULL,
    token text DEFAULT replace(((gen_random_uuid())::text || (gen_random_uuid())::text), '-'::text, ''::text) NOT NULL,
    accepted_at timestamp with time zone,
    expires_at timestamp with time zone DEFAULT (now() + '7 days'::interval)
);
--
-- Name: outbound_clicks; Type: TABLE; Schema: public; Owner: -
--
CREATE TABLE public.outbound_clicks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    clicked_at timestamp with time zone DEFAULT now() NOT NULL,
    user_id uuid,
    showtime_id uuid
);
--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -
--
CREATE TABLE public.profiles (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    email text NOT NULL,
    full_name text,
    role public.user_role DEFAULT 'user'::public.user_role NOT NULL,
    favorite_venue_ids uuid[] DEFAULT '{}'::uuid[],
    preferred_categories text[] DEFAULT '{}'::text[],
    is_verified boolean DEFAULT false NOT NULL
);
--
-- Name: showtimes; Type: TABLE; Schema: public; Owner: -
--
CREATE TABLE public.showtimes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    venue_id uuid NOT NULL,
    event_id uuid NOT NULL,
    start_time timestamp with time zone NOT NULL,
    price numeric(8,2),
    attributes jsonb DEFAULT '{}'::jsonb,
    booking_url text NOT NULL,
    status public.event_status DEFAULT 'published'::public.event_status NOT NULL,
    end_time timestamp with time zone,
    capacity integer,
    tickets_sold integer DEFAULT 0,
    image_url text
);
--
-- Name: tickets; Type: TABLE; Schema: public; Owner: -
--
CREATE TABLE public.tickets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    user_id uuid NOT NULL,
    showtime_id uuid,
    event_title text NOT NULL,
    image_url text,
    venue_name text NOT NULL,
    venue_address text,
    starts_at timestamp with time zone NOT NULL,
    ticket_code text NOT NULL,
    seat text,
    holder_name text,
    status text DEFAULT 'valid'::text NOT NULL,
    issued_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT tickets_status_check CHECK ((status = ANY (ARRAY['valid'::text, 'used'::text, 'cancelled'::text, 'refunded'::text])))
);
--
-- Name: venues; Type: TABLE; Schema: public; Owner: -
--
CREATE TABLE public.venues (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    owner_id uuid,
    name text NOT NULL,
    venue_type text NOT NULL,
    address text,
    location public.geography(Point,4326),
    website_url text,
    image_url text,
    is_active boolean DEFAULT true
);
--
-- Name: v_listings; Type: VIEW; Schema: public; Owner: -
--
CREATE VIEW public.v_listings with (security_invoker = on) as
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
--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--
ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);
--
-- Name: ingestion_sources ingestion_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--
ALTER TABLE ONLY public.ingestion_sources
    ADD CONSTRAINT ingestion_sources_pkey PRIMARY KEY (id);
--
-- Name: ingestion_sources ingestion_sources_url_key; Type: CONSTRAINT; Schema: public; Owner: -
--
ALTER TABLE ONLY public.ingestion_sources
    ADD CONSTRAINT ingestion_sources_url_key UNIQUE (url);
--
-- Name: organizer_invites organizer_invites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--
ALTER TABLE ONLY public.organizer_invites
    ADD CONSTRAINT organizer_invites_pkey PRIMARY KEY (id);
--
-- Name: organizer_invites organizer_invites_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--
ALTER TABLE ONLY public.organizer_invites
    ADD CONSTRAINT organizer_invites_token_key UNIQUE (token);
--
-- Name: outbound_clicks outbound_clicks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--
ALTER TABLE ONLY public.outbound_clicks
    ADD CONSTRAINT outbound_clicks_pkey PRIMARY KEY (id);
--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--
ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);
--
-- Name: showtimes showtimes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--
ALTER TABLE ONLY public.showtimes
    ADD CONSTRAINT showtimes_pkey PRIMARY KEY (id);
--
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--
ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (id);
--
-- Name: tickets tickets_ticket_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--
ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_ticket_code_key UNIQUE (ticket_code);
--
-- Name: venues venues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--
ALTER TABLE ONLY public.venues
    ADD CONSTRAINT venues_pkey PRIMARY KEY (id);
--
-- Name: idx_events_category; Type: INDEX; Schema: public; Owner: -
--
CREATE INDEX idx_events_category ON public.events USING btree (category);
--
-- Name: idx_organizer_invites_email; Type: INDEX; Schema: public; Owner: -
--
CREATE INDEX idx_organizer_invites_email ON public.organizer_invites USING btree (email);
--
-- Name: idx_organizer_invites_token; Type: INDEX; Schema: public; Owner: -
--
CREATE INDEX idx_organizer_invites_token ON public.organizer_invites USING btree (token);
--
-- Name: idx_organizer_invites_venue; Type: INDEX; Schema: public; Owner: -
--
CREATE INDEX idx_organizer_invites_venue ON public.organizer_invites USING btree (venue_id);
--
-- Name: idx_showtimes_attributes; Type: INDEX; Schema: public; Owner: -
--
CREATE INDEX idx_showtimes_attributes ON public.showtimes USING gin (attributes);
--
-- Name: idx_showtimes_lookup; Type: INDEX; Schema: public; Owner: -
--
CREATE INDEX idx_showtimes_lookup ON public.showtimes USING btree (venue_id, start_time, status);
--
-- Name: idx_unique_ingest_event; Type: INDEX; Schema: public; Owner: -
--
CREATE UNIQUE INDEX idx_unique_ingest_event ON public.events USING btree (((external_ids ->> 'ingest_key'::text))) WHERE ((external_ids ->> 'ingest_key'::text) IS NOT NULL);
--
-- Name: idx_unique_tmdb_event; Type: INDEX; Schema: public; Owner: -
--
CREATE UNIQUE INDEX idx_unique_tmdb_event ON public.events USING btree (((external_ids ->> 'tmdb_id'::text))) WHERE ((external_ids ->> 'tmdb_id'::text) IS NOT NULL);
--
-- Name: idx_venues_location; Type: INDEX; Schema: public; Owner: -
--
CREATE INDEX idx_venues_location ON public.venues USING gist (location);
--
-- Name: tickets_user_starts_at_idx; Type: INDEX; Schema: public; Owner: -
--
CREATE INDEX tickets_user_starts_at_idx ON public.tickets USING btree (user_id, starts_at);
--
-- Name: profiles enforce_profile_update_restrictions; Type: TRIGGER; Schema: public; Owner: -
--
CREATE TRIGGER enforce_profile_update_restrictions BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.check_profile_update();
--
-- Name: events guard_event_write; Type: TRIGGER; Schema: public; Owner: -
--
CREATE TRIGGER guard_event_write BEFORE INSERT OR UPDATE ON public.events FOR EACH ROW EXECUTE FUNCTION public.guard_event_write();
--
-- Name: events set_events_updated_at; Type: TRIGGER; Schema: public; Owner: -
--
CREATE TRIGGER set_events_updated_at BEFORE UPDATE ON public.events FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
--
-- Name: profiles set_profiles_updated_at; Type: TRIGGER; Schema: public; Owner: -
--
CREATE TRIGGER set_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
--
-- Name: showtimes set_showtimes_updated_at; Type: TRIGGER; Schema: public; Owner: -
--
CREATE TRIGGER set_showtimes_updated_at BEFORE UPDATE ON public.showtimes FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
--
-- Name: venues set_venues_updated_at; Type: TRIGGER; Schema: public; Owner: -
--
CREATE TRIGGER set_venues_updated_at BEFORE UPDATE ON public.venues FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
--
-- Name: events events_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--
ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id) ON DELETE SET NULL;
--
-- Name: organizer_invites organizer_invites_invited_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--
ALTER TABLE ONLY public.organizer_invites
    ADD CONSTRAINT organizer_invites_invited_by_fkey FOREIGN KEY (invited_by) REFERENCES public.profiles(id) ON DELETE SET NULL;
--
-- Name: organizer_invites organizer_invites_venue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--
ALTER TABLE ONLY public.organizer_invites
    ADD CONSTRAINT organizer_invites_venue_id_fkey FOREIGN KEY (venue_id) REFERENCES public.venues(id) ON DELETE CASCADE;
--
-- Name: outbound_clicks outbound_clicks_showtime_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--
ALTER TABLE ONLY public.outbound_clicks
    ADD CONSTRAINT outbound_clicks_showtime_id_fkey FOREIGN KEY (showtime_id) REFERENCES public.showtimes(id) ON DELETE SET NULL;
--
-- Name: outbound_clicks outbound_clicks_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--
ALTER TABLE ONLY public.outbound_clicks
    ADD CONSTRAINT outbound_clicks_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL;
--
-- Name: profiles profiles_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--
ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;
--
-- Name: showtimes showtimes_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--
ALTER TABLE ONLY public.showtimes
    ADD CONSTRAINT showtimes_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE RESTRICT;
--
-- Name: showtimes showtimes_venue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--
ALTER TABLE ONLY public.showtimes
    ADD CONSTRAINT showtimes_venue_id_fkey FOREIGN KEY (venue_id) REFERENCES public.venues(id) ON DELETE CASCADE;
--
-- Name: tickets tickets_showtime_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--
ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_showtime_id_fkey FOREIGN KEY (showtime_id) REFERENCES public.showtimes(id) ON DELETE SET NULL;
--
-- Name: tickets tickets_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--
ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
--
-- Name: venues venues_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--
ALTER TABLE ONLY public.venues
    ADD CONSTRAINT venues_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.profiles(id) ON DELETE RESTRICT;
--
-- Name: events Admins have full access to events; Type: POLICY; Schema: public; Owner: -
--
CREATE POLICY "Admins have full access to events" ON public.events USING ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::public.user_role)))));
--
-- Name: showtimes Admins have full access to showtimes; Type: POLICY; Schema: public; Owner: -
--
CREATE POLICY "Admins have full access to showtimes" ON public.showtimes USING ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::public.user_role)))));
--
-- Name: venues Admins have full access to venues; Type: POLICY; Schema: public; Owner: -
--
CREATE POLICY "Admins have full access to venues" ON public.venues USING ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::public.user_role)))));
--
-- Name: ingestion_sources Admins manage ingestion sources; Type: POLICY; Schema: public; Owner: -
--
CREATE POLICY "Admins manage ingestion sources" ON public.ingestion_sources USING (public.is_admin()) WITH CHECK (public.is_admin());
--
-- Name: venues Anyone can read active venues; Type: POLICY; Schema: public; Owner: -
--
CREATE POLICY "Anyone can read active venues" ON public.venues FOR SELECT USING ((is_active = true));
--
-- Name: events Anyone can read events; Type: POLICY; Schema: public; Owner: -
--
CREATE POLICY "Anyone can read events" ON public.events FOR SELECT USING (true);
--
-- Name: showtimes Anyone can read published showtimes; Type: POLICY; Schema: public; Owner: -
--
CREATE POLICY "Anyone can read published showtimes" ON public.showtimes FOR SELECT USING ((status = 'published'::public.event_status));
--
-- Name: organizer_invites Invited users can view their invite; Type: POLICY; Schema: public; Owner: -
--
CREATE POLICY "Invited users can view their invite" ON public.organizer_invites FOR SELECT USING (((lower(email) = lower(COALESCE((auth.jwt() ->> 'email'::text), ''::text))) OR (auth.uid() = invited_by)));
--
-- Name: events Partners can insert events; Type: POLICY; Schema: public; Owner: -
--
CREATE POLICY "Partners can insert events" ON public.events FOR INSERT WITH CHECK ((public.is_partner() AND (created_by = auth.uid())));
--
-- Name: showtimes Partners can manage showtimes for their venues; Type: POLICY; Schema: public; Owner: -
--
CREATE POLICY "Partners can manage showtimes for their venues" ON public.showtimes USING ((public.is_partner() AND (EXISTS ( SELECT 1
   FROM public.venues v
  WHERE ((v.id = showtimes.venue_id) AND (v.owner_id = auth.uid())))))) WITH CHECK ((public.is_partner() AND (EXISTS ( SELECT 1
   FROM public.venues v
  WHERE ((v.id = showtimes.venue_id) AND (v.owner_id = auth.uid()))))));
--
-- Name: venues Partners can manage their own venues; Type: POLICY; Schema: public; Owner: -
--
CREATE POLICY "Partners can manage their own venues" ON public.venues USING (((auth.uid() = owner_id) AND public.is_partner())) WITH CHECK (((auth.uid() = owner_id) AND public.is_partner()));
--
-- Name: events Partners can update events; Type: POLICY; Schema: public; Owner: -
--
CREATE POLICY "Partners can update events" ON public.events FOR UPDATE USING ((public.is_partner() AND (created_by = auth.uid()))) WITH CHECK ((public.is_partner() AND (created_by = auth.uid())));
--
-- Name: outbound_clicks Partners read clicks on their venues; Type: POLICY; Schema: public; Owner: -
--
CREATE POLICY "Partners read clicks on their venues" ON public.outbound_clicks FOR SELECT USING ((public.is_admin() OR (public.is_partner() AND (EXISTS ( SELECT 1
   FROM (public.showtimes s
     JOIN public.venues v ON ((v.id = s.venue_id)))
  WHERE ((s.id = outbound_clicks.showtime_id) AND (v.owner_id = auth.uid())))))));
--
-- Name: profiles Users can update own profile; Type: POLICY; Schema: public; Owner: -
--
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (((auth.uid() = id) OR public.is_admin()));
--
-- Name: profiles Users can view own profile; Type: POLICY; Schema: public; Owner: -
--
CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (((auth.uid() = id) OR public.is_admin()));
--
-- Name: organizer_invites Venue owners can manage invites; Type: POLICY; Schema: public; Owner: -
--
CREATE POLICY "Venue owners can manage invites" ON public.organizer_invites USING ((public.is_partner() AND (EXISTS ( SELECT 1
   FROM public.venues v
  WHERE ((v.id = organizer_invites.venue_id) AND (v.owner_id = auth.uid())))))) WITH CHECK ((public.is_partner() AND (EXISTS ( SELECT 1
   FROM public.venues v
  WHERE ((v.id = organizer_invites.venue_id) AND (v.owner_id = auth.uid()))))));
--
-- Name: events; Type: ROW SECURITY; Schema: public; Owner: -
--
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
--
-- Name: ingestion_sources; Type: ROW SECURITY; Schema: public; Owner: -
--
ALTER TABLE public.ingestion_sources ENABLE ROW LEVEL SECURITY;
--
-- Name: organizer_invites; Type: ROW SECURITY; Schema: public; Owner: -
--
ALTER TABLE public.organizer_invites ENABLE ROW LEVEL SECURITY;
--
-- Name: outbound_clicks; Type: ROW SECURITY; Schema: public; Owner: -
--
ALTER TABLE public.outbound_clicks ENABLE ROW LEVEL SECURITY;
--
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: -
--
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
--
-- Name: showtimes; Type: ROW SECURITY; Schema: public; Owner: -
--
ALTER TABLE public.showtimes ENABLE ROW LEVEL SECURITY;
--
-- Name: tickets; Type: ROW SECURITY; Schema: public; Owner: -
--
ALTER TABLE public.tickets ENABLE ROW LEVEL SECURITY;
--
-- Name: tickets tickets: admins manage; Type: POLICY; Schema: public; Owner: -
--
CREATE POLICY "tickets: admins manage" ON public.tickets TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
--
-- Name: tickets tickets: users read own; Type: POLICY; Schema: public; Owner: -
--
CREATE POLICY "tickets: users read own" ON public.tickets FOR SELECT TO authenticated USING ((user_id = auth.uid()));
--
-- Name: venues; Type: ROW SECURITY; Schema: public; Owner: -
--
ALTER TABLE public.venues ENABLE ROW LEVEL SECURITY;
--
--
\unrestrict NlsT1beFUKOqVC3bRywdSygzd700WBoht1n6avj3QR28ufi6NRsn2Yx0i4RKVEu
-- The signup trigger lives on auth.users (outside `public`), so pg_dump of `public` omits it.
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- Keep profiles.email in step with Supabase Auth (clients cannot edit it directly).
drop trigger if exists on_auth_user_email_changed on auth.users;
create trigger on_auth_user_email_changed
  after update of email on auth.users
  for each row when (old.email is distinct from new.email)
  execute function public.sync_profile_email();

-- Privileges are not part of the dump but are security-relevant: invites are accepted by
-- signed-in users only (S12). Supabase's default grants would otherwise re-expose it to anon.
revoke execute on function public.accept_organizer_invite(text) from public, anon;
grant execute on function public.accept_organizer_invite(text) to authenticated;

-- Account deletion grace period (migration 20261105000000_account_deletions.sql).
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

-- From 20261106000000_listings_venue_privacy.sql (S10, S6)
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

-- From 20261107000000_rate_limited_clicks.sql (S9)
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

-- No direct inserts from clients.
revoke insert on table public.outbound_clicks from anon, authenticated;

-- From 20261108000000_organizer_event_verification_venue_notes.sql (S10)
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
