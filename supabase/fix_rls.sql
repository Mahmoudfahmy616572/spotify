-- ============================================
-- Soundora RLS Full Fix
-- Run this in: Supabase Dashboard → SQL Editor
-- ============================================

-- Fix Users table: add foreign key to auth.users if missing
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'public."Users"'::regclass
      AND conname = 'Users_id_fkey'
  ) THEN
    ALTER TABLE public."Users"
      ADD CONSTRAINT Users_id_fkey
      FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;
  END IF;
END $$;

-- Fix id column to not auto-generate (must match auth.uid)
ALTER TABLE public."Users"
  ALTER COLUMN id DROP DEFAULT;

-- ========== DROP ALL EXISTING POLICIES ==========
DO $$
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN
    SELECT schemaname, tablename, policyname
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename IN ('Users', 'Songs', 'favourite_songs', 'recently_played')
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', pol.policyname, pol.schemaname, pol.tablename);
  END LOOP;

  FOR pol IN
    SELECT schemaname, tablename, policyname
    FROM pg_policies
    WHERE schemaname = 'storage'
      AND tablename = 'objects'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', pol.policyname, pol.schemaname, pol.tablename);
  END LOOP;
END $$;

-- ========== USERS TABLE ==========
CREATE POLICY "Users: insert during signup"
  ON public."Users" FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users: select own profile"
  ON public."Users" FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users: update own profile"
  ON public."Users" FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users: service_role bypass"
  ON public."Users" FOR ALL
  USING (auth.role() = 'service_role');

-- ========== SONGS TABLE ==========
CREATE POLICY "Songs: public read"
  ON public."Songs" FOR SELECT
  USING (true);

CREATE POLICY "Songs: authenticated insert"
  ON public."Songs" FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Songs: service_role bypass"
  ON public."Songs" FOR ALL
  USING (auth.role() = 'service_role');

-- ========== FAVOURITE_SONGS TABLE ==========
CREATE POLICY "Favourites: select own"
  ON public.favourite_songs FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Favourites: insert own"
  ON public.favourite_songs FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Favourites: update own"
  ON public.favourite_songs FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Favourites: delete own"
  ON public.favourite_songs FOR DELETE
  USING (auth.uid() = user_id);

CREATE POLICY "Favourites: service_role bypass"
  ON public.favourite_songs FOR ALL
  USING (auth.role() = 'service_role');

-- ========== RECENTLY_PLAYED TABLE ==========
CREATE POLICY "Recently: select own"
  ON public.recently_played FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Recently: insert own"
  ON public.recently_played FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Recently: update own"
  ON public.recently_played FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Recently: delete own"
  ON public.recently_played FOR DELETE
  USING (auth.uid() = user_id);

CREATE POLICY "Recently: service_role bypass"
  ON public.recently_played FOR ALL
  USING (auth.role() = 'service_role');

-- ========== STORAGE POLICIES ==========
CREATE POLICY "Storage: songs public read"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'songs');

CREATE POLICY "Storage: songs authenticated insert"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'songs' AND auth.role() = 'authenticated');

CREATE POLICY "Storage: songs authenticated delete"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'songs' AND auth.role() = 'authenticated');

CREATE POLICY "Storage: covers public read"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'covers');

CREATE POLICY "Storage: covers authenticated insert"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'covers' AND auth.role() = 'authenticated');

CREATE POLICY "Storage: covers authenticated delete"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'covers' AND auth.role() = 'authenticated');

CREATE POLICY "Storage: service_role bypass"
  ON storage.objects FOR ALL
  USING (auth.role() = 'service_role');
