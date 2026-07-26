-- ============================================
-- Soundora Database Setup for New Supabase Project
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- ============================================

-- 1. Enable UUID extension (needed for auth)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Users Table
CREATE TABLE IF NOT EXISTS public."Users" (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT,
  email TEXT UNIQUE,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Songs Table
CREATE TABLE IF NOT EXISTS public."Songs" (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL DEFAULT '',
  artist TEXT NOT NULL DEFAULT '',
  urlbase TEXT NOT NULL DEFAULT '',
  "imageUrl" TEXT NOT NULL DEFAULT '',
  duration TEXT NOT NULL DEFAULT '0:00',
  "releaseDate" TIMESTAMPTZ DEFAULT now(),
  lyrics TEXT DEFAULT ''
);

-- 4. favourite_songs Table
CREATE TABLE IF NOT EXISTS public.favourite_songs (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  song_id BIGINT NOT NULL REFERENCES public."Songs"(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, song_id)
);

-- 5. recently_played Table
CREATE TABLE IF NOT EXISTS public.recently_played (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  song_id BIGINT NOT NULL REFERENCES public."Songs"(id) ON DELETE CASCADE,
  played_at TIMESTAMPTZ DEFAULT now()
);

-- 6. Enable Row Level Security (RLS)
ALTER TABLE public."Users" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."Songs" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favourite_songs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recently_played ENABLE ROW LEVEL SECURITY;

-- 7. RLS Policies - Users
CREATE POLICY "Users: anyone can insert during signup"
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

-- 8. RLS Policies - Songs
CREATE POLICY "Songs: public read"
  ON public."Songs" FOR SELECT
  USING (true);

CREATE POLICY "Songs: authenticated insert"
  ON public."Songs" FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Songs: service_role bypass"
  ON public."Songs" FOR ALL
  USING (auth.role() = 'service_role');

-- 9. RLS Policies - favourite_songs
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

-- 10. RLS Policies - recently_played
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

-- 11. Storage Buckets
INSERT INTO storage.buckets (id, name, public)
VALUES ('songs', 'songs', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public)
VALUES ('covers', 'covers', true)
ON CONFLICT (id) DO NOTHING;

-- 12. Storage Policies
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
