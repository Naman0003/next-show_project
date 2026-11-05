# tmdb

TMDB proxy for the organizer app. The TMDB API key lives only in this function's secrets, so no app
binary contains it (S5). It is also the only way an event becomes `is_verified = true` from a
partner: the database trigger `guard_event_write` ignores the flag from clients, and this function
sets it with the service role after checking the movie against TMDB (S3).

```
POST /functions/v1/tmdb      Authorization: Bearer <user access token>   (verified partners and admins only)
  {"action":"search","query":"Inception"}     200 {"results":[{id,title,overview,poster_path,release_date,vote_average}]}
  {"action":"details","id":27205}             200 {"details":{id,title,overview,poster_url,runtime,director,genres,release_year}}
  {"action":"verify","event_id":"<uuid>"}     200 {"verified":true,"details":{...}}
       only the event's creator (or an admin); the event's title, description, image_url,
       duration_minutes and director/genres/release_year are overwritten with TMDB's values
  401 unauthorized · 403 verified_partners_only · 400 bad_action/bad_id/bad_event_id/no_tmdb_id
  404 not_found/tmdb_not_found · 502 tmdb_failed
```

Editing a TMDB field (title, description, image, duration, category, external_ids) afterwards drops
the flag again; the organizer app calls `verify` after every save of a TMDB-picked movie.

## Deploy

```bash
supabase secrets set TMDB_API_KEY=<your TMDB v3 API key>
supabase functions deploy tmdb            # keep JWT verification ON (the default)
```

## Test

```bash
node --test supabase/functions/tmdb/lib_test.ts
```
