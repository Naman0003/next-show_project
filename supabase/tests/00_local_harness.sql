-- Local-only scaffolding for the security tests (NOT a migration; never run on production).
-- The prod dump covers schema `public` only, so recreate what lives outside it.
create extension if not exists postgis;
create extension if not exists pgcrypto;

-- Real Supabase exposes the JWT claims through auth.jwt(); the plain image lacks it.
create or replace function auth.jwt() returns jsonb language sql stable as $$
  select coalesce(nullif(current_setting('request.jwt.claims', true), ''), '{}')::jsonb;
$$;

-- Supabase projects ship with these default grants on `public` (RLS does the real gating).
alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;
