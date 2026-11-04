# delete-account

A signed-in user asks to delete their own account (App Store 5.1.1(v), Google Play account deletion policy).
Nothing is erased immediately: the account is **deactivated** and **permanently deleted after 14 days** unless the
user signs in again and restores it. The hourly `account-deletion-maintenance` job emails a reminder 24 h before and
does the final deletion.

```
POST /functions/v1/delete-account     Authorization: Bearer <user access token>
  200 {"scheduled_for": "<ISO timestamp>"}   (a repeat request returns the original date)
  401 {"error": "unauthorized"}              missing/invalid token (the anon key is rejected too)
  409 {"error": "owns_venues"}               user still owns venues (profiles -> venues is ON DELETE RESTRICT)
  500 {"error": "delete_failed"}
```

The user id comes from the verified token, never from the request body, so a caller can only act on themselves.
The function inserts a row in `account_deletions` and revokes every session of the user (all devices).

## Flow

```
app: Profile -> Delete Account -> delete-account        row in account_deletions, sessions revoked, app signs out
user signs in again within 14 days -> app reads its own row -> "Restore your account?" -> rpc restore_account() deletes the row
day 13 (hourly job): reminder email
day 14 (hourly job): avatars removed, auth user deleted -> profiles/tickets/account_deletions cascade;
                     outbound_clicks.user_id, events.created_by, organizer_invites.invited_by become null
```

## Deploy

```bash
supabase db push                              # account_deletions table, restore_account(), hourly cron job
supabase functions deploy delete-account      # keep JWT verification ON (the default); no secrets to set
# the maintenance half is in ../account-deletion-maintenance/README.md
```

## Test

```bash
node --test supabase/functions/delete-account/lib_test.ts         # logic, no network
```

Manual, against the real project, with a throwaway account (never your own):
1. Sign up a test user in the app, then Profile -> Delete Account -> confirm. You land on the guest profile.
2. SQL editor: `select * from account_deletions;` has one row, `scheduled_for` about 14 days out.
3. Sign in with the same email: the app asks "Restore your account?". Restore -> the row is gone.
4. To test the end of the cycle without waiting, move the date and run the job:
   `update account_deletions set scheduled_for = now() + interval '20 hours' where email = '<email>';`
   then trigger `account-deletion-maintenance` (see its README): you get the reminder mail. Set `scheduled_for = now() - interval '1 minute'`
   and trigger it again: the user disappears from Authentication -> Users.
5. Calling the function with the anon key must return 401.

## Google Play

Play also requires a public web page that explains how to delete the account and what is deleted (mention the 14-day
grace period). Host it with the privacy policy and enter its URL in Play Console -> App content -> Data safety.
