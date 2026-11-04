# account-deletion-maintenance

Runs every hour (pg_cron, migration `20261105000100_account_deletion_cron.sql`) for accounts in their 14-day
deletion grace period (`account_deletions`, filled by `delete-account`):

1. **Reminder:** for rows due within the next 24 h and not yet reminded, send an email and set `reminder_sent_at`.
   A failed mail is retried every hour until the deletion date.
2. **Deletion:** for rows with `scheduled_for <= now()`, remove `avatars/<uid>/*`, then delete the auth user
   (profiles, tickets and the row itself cascade). A user who meanwhile became a venue owner is skipped and
   `last_error = 'owns_venues'` is recorded.

At most 50 rows per step per run. Time-based work uses pg_cron, not a database trigger: triggers only fire on row
changes, never on the clock.

## Setup

```bash
supabase secrets set MAINTENANCE_SECRET=$(openssl rand -hex 32)      # remember the value for the Vault step
supabase secrets set SMTP_HOST=smtp.hostinger.com SMTP_PORT=465 \
  SMTP_USER=contact@nextshow.net SMTP_PASS=... SMTP_FROM='Next Show <contact@nextshow.net>'
supabase functions deploy account-deletion-maintenance --no-verify-jwt   # auth is the x-maintenance-secret header
```

Then, once, in the SQL editor (same value as `MAINTENANCE_SECRET`):

```sql
select vault.create_secret('<MAINTENANCE_SECRET>', 'maintenance_secret');
```

Until that secret exists the cron job still fires, but the function answers 401.

## Test

```bash
node --test supabase/functions/account-deletion-maintenance/lib_test.ts     # logic + email text, no network
```

Real run (e.g. after moving a test row's `scheduled_for`, see `../delete-account/README.md`):

```bash
curl -X POST https://waqyoiheasnmtaqqayma.supabase.co/functions/v1/account-deletion-maintenance \
  -H "x-maintenance-secret: <MAINTENANCE_SECRET>"
# {"reminded":1,"deleted":0,"failed":0}
```

Logs: Dashboard -> Edge Functions -> account-deletion-maintenance -> Logs. Cron history:
`select * from cron.job_run_details order by start_time desc limit 5;`

## Notes

- Mail goes out through your own SMTP account (the same Hostinger mailbox used for Auth emails), so check its
  sending limits. Test that the mail does not land in spam before launch.
- The mail contains no link: it tells the user to sign in to the app, where they are asked to restore the account.
