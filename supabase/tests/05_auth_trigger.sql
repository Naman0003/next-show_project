-- The signup trigger lives on auth.users (outside the `public` dump). Same as docs/schema.sql.
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();
