# ingest-events

Autonomous event ingestion: crawl → Gemini structured extraction → Supabase.

```
ingestion_sources (enabled rows)
  → fetch (robots.txt respected, 15s timeout)
  → RSS items / HTML stripped to text (≤30k chars)
  → Claude (ANTHROPIC_API_KEY set) or Gemini, JSON forced by a schema
  → validate (future, ≤1 year out, ISO time with offset, http(s) URLs only)
  → dedupe on events.external_ids.ingest_key
  → venue (match by name, else create + geocode via OSM Nominatim)
  → events (is_verified = false) + showtimes
  → v_listings → apps' realtime streams
```

Ingested events are visible straight away but flagged `is_verified = false`
for admin moderation. Fields the schema has no column for (`city`,
`is_free`, `neighborhood`, `organizer`, `organizer_avatar`,
`breaking_headline`, `original_category`) live in `events.metadata`.

## Setup

```bash
supabase db push   # applies migrations/20261027000000_ingestion_sources.sql

supabase secrets set INGEST_SECRET=$(openssl rand -hex 32)
# LLM: Claude is used whenever ANTHROPIC_API_KEY is set; otherwise Gemini.
supabase secrets set ANTHROPIC_API_KEY=...   # optional CLAUDE_MODEL (default claude-haiku-5-5, the cheapest)
# or: supabase secrets set GEMINI_API_KEY=...   # optional GEMINI_MODEL (default gemini-3.5-flash-lite)

supabase functions deploy ingest-events --no-verify-jwt
```

`--no-verify-jwt` because auth is the `x-ingest-secret` header, which keeps
app users (who hold a valid anon JWT) from triggering paid crawls.

## Add sources (as admin, or in the SQL editor)

```sql
insert into public.ingestion_sources (name, url, kind, city)
values ('Example feed', 'https://example.org/events.rss', 'rss', 'Berlin');
```

Check each site's terms of use before enabling it; robots.txt is honoured
but terms may still forbid scraping.

## Run manually

```bash
curl -X POST "$SUPABASE_URL/functions/v1/ingest-events" \
  -H "x-ingest-secret: $INGEST_SECRET" -H "content-type: application/json" \
  -d '{"dry_run": true}'          # preview extraction, writes nothing
```

Add `"source_id": "<uuid>"` to run a single source.

## Schedule hourly (pg_cron + pg_net)

```sql
select vault.create_secret('<INGEST_SECRET>', 'ingest_secret');

select cron.schedule('ingest-events-hourly', '0 * * * *', $$
  select net.http_post(
    url := 'https://<project-ref>.supabase.co/functions/v1/ingest-events',
    headers := jsonb_build_object(
      'content-type', 'application/json',
      'x-ingest-secret', (select decrypted_secret from vault.decrypted_secrets where name = 'ingest_secret')
    ),
    body := '{}'::jsonb,
    timeout_milliseconds := 150000
  );
$$);
```

## Tests

```bash
node --test supabase/functions/ingest-events/lib_test.ts
```
