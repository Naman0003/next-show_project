# Supabase security tests

SQL regression tests for `security_fixes.md`. They run in a transaction and roll back, but only ever
run them on a **throwaway local Postgres, never on production** (they insert into `auth.users`).

Files
- `baseline_prod_2026-11-04.sql`: production `public` schema dump *before* the security fixes.
- `00_local_harness.sql`: what a plain Supabase Postgres image lacks (`auth.jwt()`, PostGIS, default grants).
- `05_auth_trigger.sql`: the signup trigger on `auth.users` (not part of a `public` dump).
- `10_security.test.sql`: the tests. Prints `PASS`/`FAIL` rows, then `failures | total`.

Run (Docker required; `supabase_admin` is the image's superuser)
```sh
docker run -d --name nsx-test -e POSTGRES_PASSWORD=pw -p 54399:5432 public.ecr.aws/supabase/postgres:17.6.1.155
P="docker exec -i nsx-test psql -U supabase_admin -d postgres -h localhost -q"

# 1. prove the fixes: prod baseline -> tests FAIL, then migrations -> tests PASS
$P < supabase/tests/00_local_harness.sql
$P < supabase/tests/baseline_prod_2026-11-04.sql
$P < supabase/tests/05_auth_trigger.sql
$P < supabase/tests/10_security.test.sql                 # expect failures
for f in supabase/migrations/20261104*.sql supabase/migrations/20261105000000_*.sql; do $P < $f; done   # not the cron one
$P < supabase/tests/10_security.test.sql                 # expect 0 failures

# 2. check docs/schema.sql: wipe public, load it, run the tests
$P -c "drop schema public cascade; create schema public; grant usage on schema public to anon, authenticated, service_role; create extension postgis schema public;"
$P < supabase/tests/00_local_harness.sql && $P < docs/schema.sql
$P < supabase/tests/10_security.test.sql                 # expect 0 failures

docker rm -f nsx-test
```
Add a test here for every new policy or security fix.
