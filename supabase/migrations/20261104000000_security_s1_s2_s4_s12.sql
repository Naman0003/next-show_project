-- Security fixes S1, S2, S4, S12 (see security_fixes.md).
-- Idempotent: safe to re-run. Supersedes the matching parts of docs/schema.sql.

---------------------------------------------------------
-- S1: never trust signup metadata for role.
-- Anyone can set raw_user_meta_data via /auth/v1/signup.
---------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, full_name, role)
  values (new.id, new.email, new.raw_user_meta_data->>'full_name', 'user'::user_role)
  on conflict (id) do nothing;
  return new;
end;
$$ language plpgsql security definer set search_path = public;

---------------------------------------------------------
-- S4: only handle_new_user() (SECURITY DEFINER) creates profiles.
-- The old policy let anon/authenticated insert any role.
---------------------------------------------------------
drop policy if exists "Service role can insert profiles" on public.profiles;

---------------------------------------------------------
-- S2a: profiles.email is not client-editable.
-- Keeps role/is_verified protection from the previous trigger.
---------------------------------------------------------
create or replace function public.check_profile_update()
returns trigger as $$
begin
  -- Direct DB / service-role access (no JWT) and admins are unrestricted.
  if auth.uid() is null or public.is_admin() then
    return new;
  end if;

  new.email = old.email;
  new.is_verified = old.is_verified;

  -- Users may self-upgrade to (unverified) partner; every other role change is reverted.
  if old.role is distinct from new.role
     and not (old.role = 'user'::user_role and new.role = 'partner'::user_role) then
    new.role = old.role;
  end if;

  return new;
end;
$$ language plpgsql security definer set search_path = public;

drop trigger if exists enforce_profile_update_restrictions on public.profiles;
create trigger enforce_profile_update_restrictions
  before update on public.profiles
  for each row execute function public.check_profile_update();

-- Email changes made through Supabase Auth flow into profiles from auth.users.
create or replace function public.sync_profile_email()
returns trigger as $$
begin
  update public.profiles set email = new.email where id = new.id;
  return new;
end;
$$ language plpgsql security definer set search_path = public;

drop trigger if exists on_auth_user_email_changed on auth.users;
create trigger on_auth_user_email_changed
  after update of email on auth.users
  for each row when (old.email is distinct from new.email)
  execute function public.sync_profile_email();

-- Re-sync any profile emails that were edited before this fix.
update public.profiles p set email = u.email
from auth.users u
where u.id = p.id and p.email is distinct from u.email;

---------------------------------------------------------
-- S2b: invite visibility keys off the verified auth email, not profiles.email.
---------------------------------------------------------
drop policy if exists "Invited users can view their invite" on public.organizer_invites;
create policy "Invited users can view their invite"
  on public.organizer_invites for select using (
    lower(email) = lower(coalesce(auth.jwt() ->> 'email', ''))
    or auth.uid() = invited_by
  );

---------------------------------------------------------
-- S2c: server-generated, unguessable tokens (~244 random bits).
-- The client no longer sends a token. Rotate every unaccepted invite,
-- since old tokens were timestamp-derived.
---------------------------------------------------------
alter table public.organizer_invites
  alter column token set default
    replace(gen_random_uuid()::text || gen_random_uuid()::text, '-', '');

update public.organizer_invites
set token = replace(gen_random_uuid()::text || gen_random_uuid()::text, '-', '')
where accepted_at is null;

---------------------------------------------------------
-- S2d + S12: accept only as the invited, signed-in user; never downgrade admins.
---------------------------------------------------------
create or replace function public.accept_organizer_invite(invite_token text)
returns void as $$
declare
  v_invite record;
  v_email text := lower(coalesce(auth.jwt() ->> 'email', ''));
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  select * into v_invite from public.organizer_invites
  where token = invite_token
    and accepted_at is null
    and (expires_at is null or expires_at > now())
    and lower(email) = v_email
  for update;

  if v_invite.id is null then
    raise exception 'Invalid or expired invite token';
  end if;

  update public.profiles set role = 'partner'
  where id = auth.uid() and role = 'user';

  if v_invite.role = 'owner' then
    update public.venues set owner_id = auth.uid() where id = v_invite.venue_id;
  end if;

  update public.organizer_invites set accepted_at = now() where id = v_invite.id;
end;
$$ language plpgsql security definer set search_path = public;

revoke execute on function public.accept_organizer_invite(text) from public, anon;
grant execute on function public.accept_organizer_invite(text) to authenticated;

-- Review after applying: any admin that should not exist.
--   select id, email, created_at from public.profiles where role = 'admin';
