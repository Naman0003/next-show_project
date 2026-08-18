create extension if not exists postgis;

-- Custom Types
create type user_role as enum ('user', 'partner', 'admin');
create type event_status as enum ('draft', 'published', 'cancelled');

-- Profiles (Extended Auth User)
create table if not exists public.profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    created_at timestamptz default now() not null,
    updated_at timestamptz default now() not null,
    email text not null,
    full_name text,
    role user_role default 'user'::user_role not null,
    -- User specific preferences
    favorite_venue_ids uuid[] default '{}'::uuid[],
    preferred_categories text[] default '{}'::text[]
);

-- Venues
create table if not exists public.venues (
    id uuid primary key default gen_random_uuid(),
    created_at timestamptz default now() not null,
    updated_at timestamptz default now() not null,
    owner_id uuid references public.profiles(id) on delete restrict, -- The partner who manages this venue
    name text not null,
    venue_type text not null, -- 'cinema', 'club', 'theatre'
    address text,
    location geography(point, 4326),
    website_url text,
    image_url text,
    is_active boolean default true
);

-- Events (Movies, Concerts, etc.)
create table if not exists public.events (
    id uuid primary key default gen_random_uuid(),
    created_at timestamptz default now() not null,
    updated_at timestamptz default now() not null,
    category text not null, -- 'movie', 'comedy', 'music'
    title text not null,
    description text,
    image_url text,
    duration_minutes integer,
    -- Flexible metadata for TMDB, Spotify, Eventbrite IDs
    external_ids jsonb default '{}'::jsonb,
    -- Static properties like genres, directors, or release year
    metadata jsonb default '{}'::jsonb 
);

-- Prevent duplicate movies by enforcing unique TMDB IDs
create unique index idx_unique_tmdb_event on public.events ((external_ids->>'tmdb_id'))
where (external_ids->>'tmdb_id') is not null;

-- Showtimes
create table if not exists public.showtimes (
    id uuid primary key default gen_random_uuid(),
    created_at timestamptz default now() not null,
    updated_at timestamptz default now() not null,
    venue_id uuid references public.venues(id) on delete cascade not null,
    event_id uuid references public.events(id) on delete restrict not null,
    start_time timestamptz not null,
    price numeric(8, 2),
    -- Flexible attributes for language, subtitles, format (3D/IMAX), age restrictions
    attributes jsonb default '{}'::jsonb,
    booking_url text not null,
    status event_status default 'published'::event_status not null
);

-- Analytics
create table if not exists public.outbound_clicks (
    id uuid primary key default gen_random_uuid(),
    clicked_at timestamptz default now() not null,
    user_id uuid references auth.users(id) on delete set null,
    showtime_id uuid references public.showtimes(id) on delete set null
);

---------------------------------------------------------
-- INDEXES FOR PERFORMANCE
---------------------------------------------------------
create index idx_venues_location on public.venues using gist(location);
create index idx_showtimes_lookup on public.showtimes(venue_id, start_time, status);
create index idx_events_category on public.events(category);
-- Index for quick JSONB searches (e.g. filtering by language in showtimes)
create index idx_showtimes_attributes on public.showtimes using gin (attributes);

---------------------------------------------------------
-- VIEW: ACTIVE LISTINGS
---------------------------------------------------------
create or replace view public.v_listings as
select 
  s.id as showtime_id,
  s.start_time,
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

-- PROFILES
create policy "Users can view own profile" 
on public.profiles for select using (auth.uid() = id);

create policy "Users can update own profile" 
on public.profiles for update using (auth.uid() = id);

create policy "Admins have full access to profiles" 
on public.profiles for all using (
    exists (select 1 from public.profiles where id = auth.uid() and role = 'admin')
);

-- VENUES
create policy "Anyone can read active venues" 
on public.venues for select using (is_active = true);

create policy "Partners can manage their own venues" 
on public.venues for all using (
    auth.uid() = owner_id and 
    exists (select 1 from public.profiles where id = auth.uid() and role = 'partner')
);

create policy "Admins have full access to venues" 
on public.venues for all using (
    exists (select 1 from public.profiles where id = auth.uid() and role = 'admin')
);

-- EVENTS (Shared Catalog)
create policy "Anyone can read events" 
on public.events for select using (true);

create policy "Partners can insert events" 
on public.events for insert with check (
    exists (select 1 from public.profiles where id = auth.uid() and role = 'partner')
);

create policy "Admins have full access to events" 
on public.events for all using (
    exists (select 1 from public.profiles where id = auth.uid() and role = 'admin')
);

-- SHOWTIMES
create policy "Anyone can read published showtimes" 
on public.showtimes for select using (status = 'published');

create policy "Partners can manage showtimes for their venues" 
on public.showtimes for all using (
    exists (
        select 1 from public.venues v 
        where v.id = showtimes.venue_id 
        and v.owner_id = auth.uid()
    )
);

create policy "Admins have full access to showtimes" 
on public.showtimes for all using (
    exists (select 1 from public.profiles where id = auth.uid() and role = 'admin')
);

-- OUTBOUND CLICKS (Analytics)
create policy "Users can insert their own clicks" 
on public.outbound_clicks for insert with check (auth.uid() = user_id or user_id is null);

create policy "Admins and Partners can read clicks" 
on public.outbound_clicks for select using (
    exists (select 1 from public.profiles where id = auth.uid() and role in ('admin', 'partner'))
);

---------------------------------------------------------
-- TRIGGERS
---------------------------------------------------------
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger set_venues_updated_at before update on public.venues for each row execute function public.handle_updated_at();
create trigger set_events_updated_at before update on public.events for each row execute function public.handle_updated_at();
create trigger set_showtimes_updated_at before update on public.showtimes for each row execute function public.handle_updated_at();
create trigger set_profiles_updated_at before update on public.profiles for each row execute function public.handle_updated_at();

-- Auto-create profile on signup
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
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();