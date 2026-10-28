-- Run supabase/functions/ingest-events every 6 hours (00:00, 06:00, 12:00, 18:00 UTC).
--
-- The function authenticates callers with INGEST_SECRET. The job reads it from
-- Vault at run time, so no secret lives in this file. Create it once, in the
-- SQL editor, with the same value as the function's INGEST_SECRET:
--   select vault.create_secret('<INGEST_SECRET>', 'ingest_secret');
-- Until it exists the job still fires but the function answers 401.

create extension if not exists pg_cron;
create extension if not exists pg_net with schema extensions;

-- cron.schedule upserts by job name, so re-running this is safe.
select cron.schedule(
  'ingest-events-every-6h',
  '0 */6 * * *',
  $$
  select net.http_post(
    url := 'https://waqyoiheasnmtaqqayma.supabase.co/functions/v1/ingest-events',
    headers := jsonb_build_object(
      'content-type', 'application/json',
      'x-ingest-secret', (select decrypted_secret from vault.decrypted_secrets where name = 'ingest_secret')
    ),
    body := '{}'::jsonb,
    timeout_milliseconds := 300000
  );
  $$
);
