create extension if not exists postgis;

-- Custom Types
do $$ begin
  create type user_role as enum ('user', 'partner', 'admin');
exception when duplicate_object then null;
end $$;

do $$ begin
  create type event_status as enum ('draft', 'published', 'cancelled', 'archived');
exception when duplicate_object then null;
end $$;

---------------------------------------------------------
-- HELPER FUNCTIONS (SECURITY DEFINER)
---------------------------------------------------------
create or replace function public.is_admin()
returns boolean as $$
  select exists (
    select 1 from public.profiles 
    where id = auth.uid() and role = 'admin'
  );
$$ language sql security definer set search_path = public;

create or replace function public.is_partner()
returns boolean as $$
  select exists (
    select 1 from public.profiles 
    where id = auth.uid() and role in ('partner', 'admin')
  );
$$ language sql security definer set search_path = public;

---------------------------------------------------------
-- TABLES
---------------------------------------------------------

-- 1. Profiles (Extended Auth User)
create table if not exists public.profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    created_at timestamptz default now() not null,
    updated_at timestamptz default now() not null,
    email text not null,
    full_name text,
    role user_role default 'user'::user_role not null,
    favorite_venue_ids uuid[] default '{}'::uuid[],
    preferred_categories text[] default '{}'::text[]
);

-- 2. Venues
create table if not exists public.venues (
    id uuid primary key default gen_random_uuid(),
    created_at timestamptz default now() not null,
    updated_at timestamptz default now() not null,
    owner_id uuid references public.profiles(id) on delete restrict,
    name text not null,
    venue_type text not null, -- 'cinema', 'club', 'theatre'
    address text,
    location geography(point, 4326),
    website_url text,
    image_url text,
    partner_notes text,
    is_active boolean default true
);

-- 3. Events (Movies, Concerts, etc.)
create table if not exists public.events (
    id uuid primary key default gen_random_uuid(),
    created_at timestamptz default now() not null,
    updated_at timestamptz default now() not null,
    category text not null, -- 'movie', 'comedy', 'music'
    title text not null,
    description text,
    image_url text,
    duration_minutes integer,
    external_ids jsonb default '{}'::jsonb,
    metadata jsonb default '{}'::jsonb,
    status event_status default 'published'::event_status not null
);

-- Prevent duplicate movies by enforcing unique TMDB IDs
create unique index if not exists idx_unique_tmdb_event on public.events ((external_ids->>'tmdb_id'))
where (external_ids->>'tmdb_id') is not null;

-- 4. Showtimes
create table if not exists public.showtimes (
    id uuid primary key default gen_random_uuid(),
    created_at timestamptz default now() not null,
    updated_at timestamptz default now() not null,
    venue_id uuid references public.venues(id) on delete cascade not null,
    event_id uuid references public.events(id) on delete restrict not null,
    start_time timestamptz not null,
    end_time timestamptz,
    price numeric(8, 2),
    capacity integer,
    tickets_sold integer default 0,
    attributes jsonb default '{}'::jsonb,
    booking_url text not null,
    image_url text,
    status event_status default 'published'::event_status not null
);

-- 5. Analytics (Outbound Clicks)
create table if not exists public.outbound_clicks (
    id uuid primary key default gen_random_uuid(),
    clicked_at timestamptz default now() not null,
    user_id uuid references auth.users(id) on delete set null,
    showtime_id uuid references public.showtimes(id) on delete set null
);

-- 6. Organizer Invites
create table if not exists public.organizer_invites (
    id uuid primary key default gen_random_uuid(),
    created_at timestamptz default now() not null,
    venue_id uuid references public.venues(id) on delete cascade not null,
    invited_by uuid references public.profiles(id) on delete set null,
    email text not null,
    role text default 'editor' not null, -- 'owner', 'editor', 'viewer'
    token text not null unique,
    accepted_at timestamptz,
    expires_at timestamptz default (now() + interval '7 days')
);

---------------------------------------------------------
-- INDEXES FOR PERFORMANCE
---------------------------------------------------------
create index if not exists idx_venues_location on public.venues using gist(location);
create index if not exists idx_showtimes_lookup on public.showtimes(venue_id, start_time, status);
create index if not exists idx_events_category on public.events(category);
create index if not exists idx_showtimes_attributes on public.showtimes using gin(attributes);
create index if not exists idx_organizer_invites_venue on public.organizer_invites(venue_id);
create index if not exists idx_organizer_invites_token on public.organizer_invites(token);
create index if not exists idx_organizer_invites_email on public.organizer_invites(email);

---------------------------------------------------------
-- VIEW: ACTIVE LISTINGS
---------------------------------------------------------
create or replace view public.v_listings as
select 
  s.id as showtime_id,
  s.start_time,
  s.end_time,
  s.price,
  s.attributes as showtime_attributes,
  s.booking_url,
  e.id as event_id,
  e.category,
  e.title as event_title,
  e.description as event_description,
  e.image_url,
  e.duration_minutes,
  e.metadata as event_metadata,
  v.id as venue_id,
  v.name as venue_name,
  v.venue_type,
  v.address as venue_address,
  st_x(v.location::geometry) as longitude,
  st_y(v.location::geometry) as latitude
from public.showtimes s
join public.events e on s.event_id = e.id
join public.venues v on s.venue_id = v.id
where s.start_time >= now() 
  and s.status = 'published'
  and v.is_active = true
order by s.start_time asc;

---------------------------------------------------------
-- ROW LEVEL SECURITY (RLS) POLICIES
---------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.venues enable row level security;
alter table public.events enable row level security;
alter table public.showtimes enable row level security;
alter table public.outbound_clicks enable row level security;
alter table public.organizer_invites enable row level security;

-- PROFILES
drop policy if exists "Users can view own profile" on public.profiles;
create policy "Users can view own profile" 
  on public.profiles for select using (auth.uid() = id or public.is_admin());

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile" 
  on public.profiles for update using (auth.uid() = id or public.is_admin());

drop policy if exists "Service role can insert profiles" on public.profiles;
create policy "Service role can insert profiles"
  on public.profiles for insert with check (true);

-- VENUES
drop policy if exists "Anyone can read active venues" on public.venues;
create policy "Anyone can read active venues" 
  on public.venues for select using (is_active = true or auth.uid() = owner_id or public.is_admin());

drop policy if exists "Partners can manage their own venues" on public.venues;
create policy "Partners can manage their own venues" 
  on public.venues for all using (auth.uid() = owner_id and public.is_partner());

drop policy if exists "Admins have full access to venues" on public.venues;
create policy "Admins have full access to venues" 
  on public.venues for all using (public.is_admin());

-- EVENTS (Shared Catalog)
drop policy if exists "Anyone can read events" on public.events;
create policy "Anyone can read events" 
  on public.events for select using (true);

drop policy if exists "Partners can insert events" on public.events;
create policy "Partners can insert events" 
  on public.events for insert with check (public.is_partner());

drop policy if exists "Partners can update events" on public.events;
create policy "Partners can update events" 
  on public.events for update using (public.is_partner());

drop policy if exists "Admins have full access to events" on public.events;
create policy "Admins have full access to events" 
  on public.events for all using (public.is_admin());

-- SHOWTIMES
drop policy if exists "Anyone can read published showtimes" on public.showtimes;
create policy "Anyone can read published showtimes" 
  on public.showtimes for select using (status = 'published' or public.is_partner() or public.is_admin());

drop policy if exists "Partners can manage showtimes for their venues" on public.showtimes;
create policy "Partners can manage showtimes for their venues" 
  on public.showtimes for all using (
    exists (
      select 1 from public.venues v 
      where v.id = showtimes.venue_id 
      and v.owner_id = auth.uid()
    )
  );

drop policy if exists "Admins have full access to showtimes" on public.showtimes;
create policy "Admins have full access to showtimes" 
  on public.showtimes for all using (public.is_admin());

-- OUTBOUND CLICKS (Analytics)
drop policy if exists "Users can insert their own clicks" on public.outbound_clicks;
create policy "Users can insert their own clicks" 
  on public.outbound_clicks for insert with check (auth.uid() = user_id or user_id is null);

drop policy if exists "Admins and Partners can read clicks" on public.outbound_clicks;
create policy "Admins and Partners can read clicks" 
  on public.outbound_clicks for select using (public.is_partner());

-- ORGANIZER INVITES
drop policy if exists "Venue owners can manage invites" on public.organizer_invites;
create policy "Venue owners can manage invites"
  on public.organizer_invites for all using (
    exists (
      select 1 from public.venues v
      where v.id = organizer_invites.venue_id
      and v.owner_id = auth.uid()
    )
  );

drop policy if exists "Invited users can view their invite" on public.organizer_invites;
create policy "Invited users can view their invite"
  on public.organizer_invites for select using (
    email = (select email from public.profiles where id = auth.uid())
    or auth.uid() = invited_by
  );

---------------------------------------------------------
-- FUNCTIONS & TRIGGERS
---------------------------------------------------------

-- 1. Automatic updated_at timestamp trigger
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists set_venues_updated_at on public.venues;
create trigger set_venues_updated_at before update on public.venues for each row execute function public.handle_updated_at();

drop trigger if exists set_events_updated_at on public.events;
create trigger set_events_updated_at before update on public.events for each row execute function public.handle_updated_at();

drop trigger if exists set_showtimes_updated_at on public.showtimes;
create trigger set_showtimes_updated_at before update on public.showtimes for each row execute function public.handle_updated_at();

drop trigger if exists set_profiles_updated_at on public.profiles;
create trigger set_profiles_updated_at before update on public.profiles for each row execute function public.handle_updated_at();

-- 2. Auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, full_name, role)
  values (
    new.id, 
    new.email, 
    new.raw_user_meta_data->>'full_name',
    coalesce((new.raw_user_meta_data->>'role')::user_role, 'user'::user_role)
  );
  return new;
end;
$$ language plpgsql security definer set search_path = public;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 3. Accept organizer invite RPC function
create or replace function public.accept_organizer_invite(invite_token text)
returns void as $$
declare
  v_invite record;
begin
  select * into v_invite from public.organizer_invites
  where token = invite_token and accepted_at is null and (expires_at is null or expires_at > now());

  if v_invite.id is null then
    raise exception 'Invalid or expired invite token';
  end if;

  -- Mark profile role as partner
  update public.profiles set role = 'partner' where id = auth.uid();

  -- Update venue ownership if role is owner
  if v_invite.role = 'owner' then
    update public.venues set owner_id = auth.uid() where id = v_invite.venue_id;
  end if;

  -- Mark invite accepted
  update public.organizer_invites set accepted_at = now() where id = v_invite.id;
end;
$$ language plpgsql security definer set search_path = public;
