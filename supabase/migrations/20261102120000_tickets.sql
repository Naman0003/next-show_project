-- Tickets shown on the user app's Tickets page (Upcoming / Past).
--
-- Each row is one admitted person for one showtime. Event details are
-- snapshotted onto the ticket so it still renders if the showtime or event is
-- later edited or removed. Users can only read their own tickets; issuing and
-- changing tickets is admin-only for now (organiser issuing comes later).

create table if not exists public.tickets (
    id uuid primary key default gen_random_uuid(),
    created_at timestamptz default now() not null,
    updated_at timestamptz default now() not null,

    user_id uuid not null references auth.users(id) on delete cascade,
    showtime_id uuid references public.showtimes(id) on delete set null,

    -- Snapshot of what the ticket is for.
    event_title text not null,
    image_url text,
    venue_name text not null,
    venue_address text,
    starts_at timestamptz not null,

    -- What gets checked at the door.
    ticket_code text not null unique,
    seat text,
    holder_name text,
    status text not null default 'valid'
        check (status in ('valid', 'used', 'cancelled', 'refunded')),
    issued_at timestamptz default now() not null
);
create index if not exists tickets_user_starts_at_idx
    on public.tickets (user_id, starts_at);
alter table public.tickets enable row level security;
create policy "tickets: users read own"
    on public.tickets for select
    to authenticated
    using (user_id = auth.uid());
create policy "tickets: admins manage"
    on public.tickets for all
    to authenticated
    using (public.is_admin())
    with check (public.is_admin());
