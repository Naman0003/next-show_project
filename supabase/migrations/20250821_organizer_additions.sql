-- Supabase migration: Organizer app additions
-- Date: 2025-08-21

-- 1. Add missing fields to showtimes
ALTER TABLE public.showtimes
  ADD COLUMN IF NOT EXISTS end_time timestamptz,
  ADD COLUMN IF NOT EXISTS capacity integer,
  ADD COLUMN IF NOT EXISTS tickets_sold integer DEFAULT 0,
  ADD COLUMN IF NOT EXISTS image_url text;

-- 2. Add event_status enum & status column to events if not present
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'event_status') THEN
    CREATE TYPE event_status AS ENUM ('draft', 'published', 'cancelled', 'archived');
  END IF;
END $$;

ALTER TABLE public.events
  ADD COLUMN IF NOT EXISTS status event_status DEFAULT 'published';

-- 3. Add partner_notes to venues
ALTER TABLE public.venues
  ADD COLUMN IF NOT EXISTS partner_notes text;

-- 4. Create organizer_invites table
CREATE TABLE IF NOT EXISTS public.organizer_invites (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  venue_id uuid REFERENCES public.venues(id) ON DELETE CASCADE,
  invited_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  email text NOT NULL,
  role text NOT NULL DEFAULT 'editor', -- 'owner', 'editor', 'viewer'
  token text NOT NULL UNIQUE,
  accepted_at timestamptz,
  expires_at timestamptz DEFAULT (now() + interval '7 days')
);

-- RLS for organizer_invites
ALTER TABLE public.organizer_invites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Venue owners can manage invites" ON public.organizer_invites
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.venues v
      WHERE v.id = venue_id AND v.owner_id = auth.uid()
    )
  );

-- 5. Updated_at trigger for profiles
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_profiles_updated_at ON public.profiles;
CREATE TRIGGER set_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

-- RPC helper to accept invite
CREATE OR REPLACE FUNCTION public.accept_organizer_invite(invite_token text)
RETURNS void AS $$
DECLARE
  v_invite record;
BEGIN
  SELECT * INTO v_invite FROM public.organizer_invites
  WHERE token = invite_token AND accepted_at IS NULL AND (expires_at IS NULL OR expires_at > now());

  IF v_invite.id IS NULL THEN
    RAISE EXCEPTION 'Invalid or expired invite token';
  END IF;

  -- Mark profile role as partner
  UPDATE public.profiles SET role = 'partner' WHERE id = auth.uid();

  -- Update venue ownership if role is owner, or store access
  IF v_invite.role = 'owner' THEN
    UPDATE public.venues SET owner_id = auth.uid() WHERE id = v_invite.venue_id;
  END IF;

  -- Mark invite accepted
  UPDATE public.organizer_invites SET accepted_at = now() WHERE id = v_invite.id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
