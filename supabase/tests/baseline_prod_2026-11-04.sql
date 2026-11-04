


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE TYPE "public"."event_status" AS ENUM (
    'draft',
    'published',
    'cancelled'
);


ALTER TYPE "public"."event_status" OWNER TO "postgres";


CREATE TYPE "public"."user_role" AS ENUM (
    'user',
    'partner',
    'admin'
);


ALTER TYPE "public"."user_role" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."accept_organizer_invite"("invite_token" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_invite record;
BEGIN
  SELECT * INTO v_invite FROM public.organizer_invites
  WHERE token = invite_token AND accepted_at IS NULL AND (expires_at IS NULL OR expires_at > now());

  IF v_invite.id IS NULL THEN
    RAISE EXCEPTION 'Invalid or expired invite token';
  END IF;

  -- Mark profile role as partner
  UPDATE public.profiles SET role = 'partner' WHERE id = auth.uid();

  -- Update venue ownership if role is owner
  IF v_invite.role = 'owner' THEN
    UPDATE public.venues SET owner_id = auth.uid() WHERE id = v_invite.venue_id;
  END IF;

  -- Mark invite accepted
  UPDATE public.organizer_invites SET accepted_at = now() WHERE id = v_invite.id;
END;
$$;


ALTER FUNCTION "public"."accept_organizer_invite"("invite_token" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_profile_update"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  -- If update is made directly in DB (auth.uid() is null) or by an admin, allow it
  if auth.uid() is null or public.is_admin() then
    return new;
  end if;

  -- Prevent clients from changing is_verified
  if (old.is_verified is distinct from new.is_verified) then
    new.is_verified = old.is_verified;
  end if;

  -- Allow user→partner upgrade only; block everything else
  if (old.role is distinct from new.role) then
    if (old.role = 'user'::user_role and new.role = 'partner'::user_role) then
      null; -- Allowed
    else
      new.role = old.role;
    end if;
  end if;

  return new;
end;
$$;


ALTER FUNCTION "public"."check_profile_update"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  insert into public.profiles (id, email, full_name, role)
  values (
    new.id,
    new.email,
    new.raw_user_meta_data->>'full_name',
    coalesce(
      (new.raw_user_meta_data->>'role')::public.user_role,
      'user'::public.user_role
    )
  );
  return new;
end;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  new.updated_at = now();
  return new;
end;
$$;


ALTER FUNCTION "public"."handle_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_admin"() RETURNS boolean
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select exists (
    select 1 from public.profiles 
    where id = auth.uid() and role = 'admin'
  );
$$;


ALTER FUNCTION "public"."is_admin"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_partner"() RETURNS boolean
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = auth.uid() 
      AND (role = 'admin' OR (role = 'partner' AND is_verified = true))
  );
$$;


ALTER FUNCTION "public"."is_partner"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."events" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "category" "text" NOT NULL,
    "title" "text" NOT NULL,
    "description" "text",
    "image_url" "text",
    "duration_minutes" integer,
    "external_ids" "jsonb" DEFAULT '{}'::"jsonb",
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "status" "public"."event_status" DEFAULT 'published'::"public"."event_status",
    "is_verified" boolean DEFAULT true NOT NULL
);


ALTER TABLE "public"."events" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."ingestion_sources" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "name" "text" NOT NULL,
    "url" "text" NOT NULL,
    "kind" "text" NOT NULL,
    "city" "text" DEFAULT 'Berlin'::"text" NOT NULL,
    "is_enabled" boolean DEFAULT true NOT NULL,
    "last_run_at" timestamp with time zone,
    "last_status" "text",
    CONSTRAINT "ingestion_sources_kind_check" CHECK (("kind" = ANY (ARRAY['rss'::"text", 'html'::"text"])))
);


ALTER TABLE "public"."ingestion_sources" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."organizer_invites" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "venue_id" "uuid" NOT NULL,
    "invited_by" "uuid",
    "email" "text" NOT NULL,
    "role" "text" DEFAULT 'editor'::"text" NOT NULL,
    "token" "text" NOT NULL,
    "accepted_at" timestamp with time zone,
    "expires_at" timestamp with time zone DEFAULT ("now"() + '7 days'::interval)
);


ALTER TABLE "public"."organizer_invites" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."outbound_clicks" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "clicked_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "user_id" "uuid",
    "showtime_id" "uuid"
);


ALTER TABLE "public"."outbound_clicks" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "email" "text" NOT NULL,
    "full_name" "text",
    "role" "public"."user_role" DEFAULT 'user'::"public"."user_role" NOT NULL,
    "favorite_venue_ids" "uuid"[] DEFAULT '{}'::"uuid"[],
    "preferred_categories" "text"[] DEFAULT '{}'::"text"[],
    "is_verified" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."showtimes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "venue_id" "uuid" NOT NULL,
    "event_id" "uuid" NOT NULL,
    "start_time" timestamp with time zone NOT NULL,
    "price" numeric(8,2),
    "attributes" "jsonb" DEFAULT '{}'::"jsonb",
    "booking_url" "text" NOT NULL,
    "status" "public"."event_status" DEFAULT 'published'::"public"."event_status" NOT NULL,
    "end_time" timestamp with time zone,
    "capacity" integer,
    "tickets_sold" integer DEFAULT 0,
    "image_url" "text"
);


ALTER TABLE "public"."showtimes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."tickets" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "showtime_id" "uuid",
    "event_title" "text" NOT NULL,
    "image_url" "text",
    "venue_name" "text" NOT NULL,
    "venue_address" "text",
    "starts_at" timestamp with time zone NOT NULL,
    "ticket_code" "text" NOT NULL,
    "seat" "text",
    "holder_name" "text",
    "status" "text" DEFAULT 'valid'::"text" NOT NULL,
    "issued_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "tickets_status_check" CHECK (("status" = ANY (ARRAY['valid'::"text", 'used'::"text", 'cancelled'::"text", 'refunded'::"text"])))
);


ALTER TABLE "public"."tickets" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."venues" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "owner_id" "uuid",
    "name" "text" NOT NULL,
    "venue_type" "text" NOT NULL,
    "address" "text",
    "location" "public"."geography"(Point,4326),
    "website_url" "text",
    "image_url" "text",
    "is_active" boolean DEFAULT true,
    "partner_notes" "text"
);


ALTER TABLE "public"."venues" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."v_listings" AS
 SELECT "s"."id" AS "showtime_id",
    "s"."start_time",
    "s"."end_time",
    "s"."price",
    "s"."attributes" AS "showtime_attributes",
    "s"."booking_url",
    "e"."id" AS "event_id",
    "e"."category",
    "e"."title" AS "event_title",
    "e"."description" AS "event_description",
    "e"."image_url",
    "e"."duration_minutes",
    "e"."metadata" AS "event_metadata",
    "e"."is_verified" AS "event_is_verified",
    "v"."id" AS "venue_id",
    "v"."name" AS "venue_name",
    "v"."venue_type",
    "v"."address" AS "venue_address",
    "public"."st_x"(("v"."location")::"public"."geometry") AS "longitude",
    "public"."st_y"(("v"."location")::"public"."geometry") AS "latitude"
   FROM (("public"."showtimes" "s"
     JOIN "public"."events" "e" ON (("s"."event_id" = "e"."id")))
     JOIN "public"."venues" "v" ON (("s"."venue_id" = "v"."id")))
  WHERE (("s"."start_time" >= "now"()) AND ("s"."status" = 'published'::"public"."event_status") AND ("v"."is_active" = true))
  ORDER BY "s"."start_time";


ALTER VIEW "public"."v_listings" OWNER TO "postgres";


ALTER TABLE ONLY "public"."events"
    ADD CONSTRAINT "events_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."ingestion_sources"
    ADD CONSTRAINT "ingestion_sources_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."ingestion_sources"
    ADD CONSTRAINT "ingestion_sources_url_key" UNIQUE ("url");



ALTER TABLE ONLY "public"."organizer_invites"
    ADD CONSTRAINT "organizer_invites_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."organizer_invites"
    ADD CONSTRAINT "organizer_invites_token_key" UNIQUE ("token");



ALTER TABLE ONLY "public"."outbound_clicks"
    ADD CONSTRAINT "outbound_clicks_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."showtimes"
    ADD CONSTRAINT "showtimes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."tickets"
    ADD CONSTRAINT "tickets_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."tickets"
    ADD CONSTRAINT "tickets_ticket_code_key" UNIQUE ("ticket_code");



ALTER TABLE ONLY "public"."venues"
    ADD CONSTRAINT "venues_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_events_category" ON "public"."events" USING "btree" ("category");



CREATE INDEX "idx_organizer_invites_email" ON "public"."organizer_invites" USING "btree" ("email");



CREATE INDEX "idx_organizer_invites_token" ON "public"."organizer_invites" USING "btree" ("token");



CREATE INDEX "idx_organizer_invites_venue" ON "public"."organizer_invites" USING "btree" ("venue_id");



CREATE INDEX "idx_showtimes_attributes" ON "public"."showtimes" USING "gin" ("attributes");



CREATE INDEX "idx_showtimes_lookup" ON "public"."showtimes" USING "btree" ("venue_id", "start_time", "status");



CREATE UNIQUE INDEX "idx_unique_ingest_event" ON "public"."events" USING "btree" ((("external_ids" ->> 'ingest_key'::"text"))) WHERE (("external_ids" ->> 'ingest_key'::"text") IS NOT NULL);



CREATE UNIQUE INDEX "idx_unique_tmdb_event" ON "public"."events" USING "btree" ((("external_ids" ->> 'tmdb_id'::"text"))) WHERE (("external_ids" ->> 'tmdb_id'::"text") IS NOT NULL);



CREATE INDEX "idx_venues_location" ON "public"."venues" USING "gist" ("location");



CREATE INDEX "tickets_user_starts_at_idx" ON "public"."tickets" USING "btree" ("user_id", "starts_at");



CREATE OR REPLACE TRIGGER "enforce_profile_update_restrictions" BEFORE UPDATE ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."check_profile_update"();



CREATE OR REPLACE TRIGGER "set_events_updated_at" BEFORE UPDATE ON "public"."events" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "set_profiles_updated_at" BEFORE UPDATE ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "set_showtimes_updated_at" BEFORE UPDATE ON "public"."showtimes" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "set_venues_updated_at" BEFORE UPDATE ON "public"."venues" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



ALTER TABLE ONLY "public"."organizer_invites"
    ADD CONSTRAINT "organizer_invites_invited_by_fkey" FOREIGN KEY ("invited_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."organizer_invites"
    ADD CONSTRAINT "organizer_invites_venue_id_fkey" FOREIGN KEY ("venue_id") REFERENCES "public"."venues"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."outbound_clicks"
    ADD CONSTRAINT "outbound_clicks_showtime_id_fkey" FOREIGN KEY ("showtime_id") REFERENCES "public"."showtimes"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."outbound_clicks"
    ADD CONSTRAINT "outbound_clicks_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."showtimes"
    ADD CONSTRAINT "showtimes_event_id_fkey" FOREIGN KEY ("event_id") REFERENCES "public"."events"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."showtimes"
    ADD CONSTRAINT "showtimes_venue_id_fkey" FOREIGN KEY ("venue_id") REFERENCES "public"."venues"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."tickets"
    ADD CONSTRAINT "tickets_showtime_id_fkey" FOREIGN KEY ("showtime_id") REFERENCES "public"."showtimes"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."tickets"
    ADD CONSTRAINT "tickets_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."venues"
    ADD CONSTRAINT "venues_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "public"."profiles"("id") ON DELETE RESTRICT;



CREATE POLICY "Admins and Partners can read clicks" ON "public"."outbound_clicks" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."role" = ANY (ARRAY['admin'::"public"."user_role", 'partner'::"public"."user_role"]))))));



CREATE POLICY "Admins have full access to events" ON "public"."events" USING ((EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."role" = 'admin'::"public"."user_role")))));



CREATE POLICY "Admins have full access to showtimes" ON "public"."showtimes" USING ((EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."role" = 'admin'::"public"."user_role")))));



CREATE POLICY "Admins have full access to venues" ON "public"."venues" USING ((EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."role" = 'admin'::"public"."user_role")))));



CREATE POLICY "Admins manage ingestion sources" ON "public"."ingestion_sources" USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



CREATE POLICY "Anyone can read active venues" ON "public"."venues" FOR SELECT USING (("is_active" = true));



CREATE POLICY "Anyone can read events" ON "public"."events" FOR SELECT USING (true);



CREATE POLICY "Anyone can read published showtimes" ON "public"."showtimes" FOR SELECT USING (("status" = 'published'::"public"."event_status"));



CREATE POLICY "Invited users can view their invite" ON "public"."organizer_invites" FOR SELECT USING ((("email" = ( SELECT "profiles"."email"
   FROM "public"."profiles"
  WHERE ("profiles"."id" = "auth"."uid"()))) OR ("auth"."uid"() = "invited_by")));



CREATE POLICY "Partners can insert events" ON "public"."events" FOR INSERT WITH CHECK ("public"."is_partner"());



CREATE POLICY "Partners can manage showtimes for their venues" ON "public"."showtimes" USING ((EXISTS ( SELECT 1
   FROM "public"."venues" "v"
  WHERE (("v"."id" = "showtimes"."venue_id") AND ("v"."owner_id" = "auth"."uid"())))));



CREATE POLICY "Partners can manage their own venues" ON "public"."venues" USING ((("auth"."uid"() = "owner_id") AND (EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."role" = 'partner'::"public"."user_role"))))));



CREATE POLICY "Partners can update events" ON "public"."events" FOR UPDATE USING ("public"."is_partner"());



CREATE POLICY "Service role can insert profiles" ON "public"."profiles" FOR INSERT WITH CHECK (true);



CREATE POLICY "Users can insert their own clicks" ON "public"."outbound_clicks" FOR INSERT WITH CHECK ((("auth"."uid"() = "user_id") OR ("user_id" IS NULL)));



CREATE POLICY "Users can update own profile" ON "public"."profiles" FOR UPDATE USING ((("auth"."uid"() = "id") OR "public"."is_admin"()));



CREATE POLICY "Users can view own profile" ON "public"."profiles" FOR SELECT USING ((("auth"."uid"() = "id") OR "public"."is_admin"()));



CREATE POLICY "Venue owners can manage invites" ON "public"."organizer_invites" USING ((EXISTS ( SELECT 1
   FROM "public"."venues" "v"
  WHERE (("v"."id" = "organizer_invites"."venue_id") AND ("v"."owner_id" = "auth"."uid"())))));



ALTER TABLE "public"."events" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."ingestion_sources" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."organizer_invites" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."outbound_clicks" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."showtimes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."tickets" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "tickets: admins manage" ON "public"."tickets" TO "authenticated" USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



CREATE POLICY "tickets: users read own" ON "public"."tickets" FOR SELECT TO "authenticated" USING (("user_id" = "auth"."uid"()));



ALTER TABLE "public"."venues" ENABLE ROW LEVEL SECURITY;


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON FUNCTION "public"."accept_organizer_invite"("invite_token" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."accept_organizer_invite"("invite_token" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."accept_organizer_invite"("invite_token" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."check_profile_update"() TO "anon";
GRANT ALL ON FUNCTION "public"."check_profile_update"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_profile_update"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_admin"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_admin"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_admin"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_partner"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_partner"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_partner"() TO "service_role";



GRANT ALL ON TABLE "public"."events" TO "anon";
GRANT ALL ON TABLE "public"."events" TO "authenticated";
GRANT ALL ON TABLE "public"."events" TO "service_role";



GRANT ALL ON TABLE "public"."ingestion_sources" TO "anon";
GRANT ALL ON TABLE "public"."ingestion_sources" TO "authenticated";
GRANT ALL ON TABLE "public"."ingestion_sources" TO "service_role";



GRANT ALL ON TABLE "public"."organizer_invites" TO "anon";
GRANT ALL ON TABLE "public"."organizer_invites" TO "authenticated";
GRANT ALL ON TABLE "public"."organizer_invites" TO "service_role";



GRANT ALL ON TABLE "public"."outbound_clicks" TO "anon";
GRANT ALL ON TABLE "public"."outbound_clicks" TO "authenticated";
GRANT ALL ON TABLE "public"."outbound_clicks" TO "service_role";



GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";



GRANT ALL ON TABLE "public"."showtimes" TO "anon";
GRANT ALL ON TABLE "public"."showtimes" TO "authenticated";
GRANT ALL ON TABLE "public"."showtimes" TO "service_role";



GRANT ALL ON TABLE "public"."tickets" TO "anon";
GRANT ALL ON TABLE "public"."tickets" TO "authenticated";
GRANT ALL ON TABLE "public"."tickets" TO "service_role";



GRANT ALL ON TABLE "public"."venues" TO "anon";
GRANT ALL ON TABLE "public"."venues" TO "authenticated";
GRANT ALL ON TABLE "public"."venues" TO "service_role";



GRANT ALL ON TABLE "public"."v_listings" TO "anon";
GRANT ALL ON TABLE "public"."v_listings" TO "authenticated";
GRANT ALL ON TABLE "public"."v_listings" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";







