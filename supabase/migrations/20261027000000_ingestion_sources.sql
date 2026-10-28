-- Autonomous event ingestion (supabase/functions/ingest-events).
-- Additive only: one new table + one new partial index on events.

---------------------------------------------------------
-- Crawl targets. Admin-managed; the edge function reads
-- enabled rows with the service role (bypasses RLS).
---------------------------------------------------------
create table if not exists public.ingestion_sources (
    id uuid primary key default gen_random_uuid(),
    created_at timestamptz default now() not null,
    name text not null,
    url text not null unique,
    kind text not null check (kind in ('rss', 'html')),
    city text default 'Berlin' not null,
    is_enabled boolean default true not null,
    last_run_at timestamptz,
    last_status text
);

alter table public.ingestion_sources enable row level security;

drop policy if exists "Admins manage ingestion sources" on public.ingestion_sources;
create policy "Admins manage ingestion sources"
  on public.ingestion_sources for all
  using (public.is_admin())
  with check (public.is_admin());

---------------------------------------------------------
-- Dedupe: each ingested event carries a deterministic
-- external_ids.ingest_key (sha256 of source|title|start),
-- so re-crawling the same page never inserts it twice.
---------------------------------------------------------
create unique index if not exists idx_unique_ingest_event on public.events ((external_ids->>'ingest_key'))
where (external_ids->>'ingest_key') is not null;
