-- Run supabase/functions/account-deletion-maintenance every hour: it emails the 24h reminder
-- and permanently deletes accounts whose 14-day grace period is over.
--
-- A database trigger only fires on row changes, never on the clock, so pg_cron is what makes
-- this "happen at a time". Like ingest-events, the job authenticates with a shared secret
-- read from Vault at run time, so no secret lives in this file. Create it once in the SQL
-- editor, with the same value as the function's MAINTENANCE_SECRET:
--   select vault.create_secret('<MAINTENANCE_SECRET>', 'maintenance_secret');
-- Until it exists the job still fires but the function answers 401.

create extension if not exists pg_cron;
create extension if not exists pg_net with schema extensions;

-- cron.schedule upserts by job name, so re-running this is safe.
select cron.schedule(
  'account-deletion-maintenance-hourly',
  '0 * * * *',
  $$
  select net.http_post(
    url := 'https://waqyoiheasnmtaqqayma.supabase.co/functions/v1/account-deletion-maintenance',
    headers := jsonb_build_object(
      'content-type', 'application/json',
      'x-maintenance-secret', (select decrypted_secret from vault.decrypted_secrets where name = 'maintenance_secret')
    ),
    body := '{}'::jsonb,
    timeout_milliseconds := 120000
  );
  $$
);
