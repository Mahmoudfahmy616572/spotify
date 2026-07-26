# Soundora API Integration — Execution Plan
# الخطة التنفيذية الكاملة

---

## PHASE 1: Deezer API Integration ( الأساسي —Week 1)

### 1.1 Data Layer

#### Data Source: `deezer_data_source.dart`
- `searchTracks(query)` → GET https://api.deezer.com/2.0/search?q={query}
- `getTopTracks(country)` → GET https://api.deezer.com/2.0/chart/{country}/tracks
- `getTopAlbums(country)` → GET https://api.deezer.com/2.0/chart/{country}/albums
- `getTopArtists(country)` → GET https://api.deezer.com/2.0/chart/{country}/artists
- `getTrack(id)` → GET https://api.deezer.com/2.0/track/{id}
- `getAlbum(id)` → GET https://api.deezer.com/2.0/album/{id}
- `getArtist(id)` → GET https://api.deezer.com/2.0/artist/{id}
- `getArtistTopTracks(id)` → GET https://api.deezer.com/2.0/artist/{id}/top
- `getEditorialCharts()` → GET https://api.deezer.com/2.0/chart
- `searchAutocomplete(query)` → GET https://api.deezer.com/2.0/search/autocomplete?q={query}

#### Model: `deezer_track_model.dart`
- Map Deezer JSON → SongModel (reuse existing model)
- Fields: id, title, artist.name, album.title, preview (30s MP3), album.cover_xl, duration

#### Repository: `songs_repository.dart` (NEW — fixes broken architecture)
- Abstract interface in domain layer
- Impl calls DeezerDataSource for online + keeps Supabase fallback

### 1.2 Domain Layer

#### Use Cases:
- `SearchSongsUsecase` — search via Deezer
- `GetChartsUsecase` — top tracks/albums by country
- `GetArtistTopTracksUsecase` — artist's popular songs
- `GetSongDetailsUsecase` — full track info

### 1.3 Presentation Layer

#### Cubits:
- `SearchSongsCubit` — REWRITE to use Deezer API instead of Supabase direct
- `ChartsCubit` — NEW — loads top tracks/albums
- `HomeSongsCubit` — REWRITE GetSongsCubit to load charts

#### UI Changes:
- **HomePage**: Show charts (Top Songs Egypt + New Releases) instead of dummy songs
- **SearchPage**: Search via Deezer with autocomplete
- **NewSongs widget**: Show trending/top songs
- **PlayList widget**: Show curated playlists from Deezer

### 1.4 Files to Create/Modify:
```
NEW:
  lib/data/sources/deezer/deezer_data_source.dart
  lib/data/sources/deezer/models/deezer_track_model.dart
  lib/data/sources/deezer/models/deezer_album_model.dart
  lib/data/sources/deezer/models/deezer_artist_model.dart
  lib/domain/repositories/songs/songs_repository.dart
  lib/data/repositories/songs/songs_repository_impl.dart
  lib/domain/usecase/songs/search_songs_usecase.dart
  lib/domain/usecase/songs/get_charts_usecase.dart
  lib/presentation/Home/cubit/charts/charts_cubit.dart
  lib/presentation/Home/cubit/charts/charts_state.dart

MODIFY:
  lib/serviece_locator.dart — register DeezerDataSource, new usecases
  lib/presentation/Home/pages/home_page.dart — use ChartsCubit
  lib/presentation/Home/widgets/new_songs.dart — show Deezer charts
  lib/presentation/Home/widgets/play_list.dart — show Deezer playlists
  lib/presentation/SearchPage/cubit/cubit/search_songs_cubit.dart — use Deezer
  lib/data/models/songs/songs_model.dart — ensure Deezer compat
```

---

## PHASE 2: TheAudioDB — Music Canvas (Week 2)

### 2.1 Data Layer
- `audiodb_data_source.dart` — fetch music videos, artist images, bio
- Endpoint: GET https://www.theaudiodb.com/api/v1/json/123/mvid.php?i={artist_id}

### 2.2 Features:
- **Music Canvas** — video loop behind album art in player
- **Artist Page** — artist images + bio from TheAudioDB
- **Related Videos** — music videos for any artist

### 2.3 Files:
```
NEW:
  lib/data/sources/audiodb/audiodb_data_source.dart
  lib/data/sources/audiodb/models/audiodb_video_model.dart
  lib/presentation/songsPlayPage/widgets/music_canvas.dart
```

---

## PHASE 3: Sound DNA + Tap to Identify (Week 3)

### 3.1 Sound DNA (Music I Want API)
- `music_iwant_data_source.dart`
- Endpoint: GET https://musiciwant.com/api/v1/song?title=&artist=
- Returns: BPM, energy, mood, intensity, recommended uses
- UI: Show "Sound DNA" card in player — visual breakdown of the song

### 3.2 Tap to Identify (AudD API)
- `audd_data_source.dart`
- Endpoint: POST https://api.audd.io/
- Send audio from mic → identify song → add to library
- UI: Floating mic button in player or search page

### 3.3 Files:
```
NEW:
  lib/data/sources/music_iwant/music_iwant_data_source.dart
  lib/data/sources/audd/audd_data_source.dart
  lib/presentation/songsPlayPage/widgets/sound_dna_card.dart
  lib/presentation/SearchPage/widgets/tap_to_identify_button.dart
```

---

## PHASE 4: wolfXspotify + Enhanced Search (Week 3-4)

### 4.1 Enhanced Metadata
- Use wolfXspotify-API for Spotify-grade metadata
- Artist genres, popularity, discography
- Better search results with Spotify data enrichment

### 4.2 Artist Page (NEW screen)
- Artist photo + bio (from TheAudioDB + wolfXspotify)
- Top tracks (from Deezer + wolfXspotify)
- Discography (albums, singles, EPs)
- Related artists
- Similar artists (from Last.fm)

### 4.3 Files:
```
NEW:
  lib/data/sources/wolfxspotify/wolfxspotify_data_source.dart
  lib/presentation/ArtistPage/artist_page.dart
  lib/presentation/ArtistPage/cubit/artist_cubit.dart
```

---

## PHASE 5: Verome API — YouTube Music Streaming (Week 4-5)

### 5.1 Full Song Streaming
- Use Verome API for full song playback (beyond Deezer's 30s)
- YouTube Music as streaming source
- Proxy through Verome for audio stream URLs

### 5.2 Charts + Trending
- Country-specific charts from Verome
- Trending music
- Mood-based playlists

### 5.3 Files:
```
NEW:
  lib/data/sources/verome/verome_data_source.dart
  lib/domain/usecase/songs/get_full_stream_usecase.dart
```

---

## PHASE 6: Gamification + Social (Week 5-6)

### 6.1 Achievement System
- Track listening stats in Hive
- Unlock achievements based on behavior
- XP + Levels + Leaderboard

### 6.2 Listening Party
- WebSocket-based shared rooms
- Real-time sync playback
- Chat + Vibe Check

### 6.3 Music Card
- Generate beautiful share cards
- Share via WhatsApp/Social media
- Deep linking to play song

---

## Implementation Order (Priority):
1. **Deezer API** (Phase 1) — replaces dummy songs, adds charts/search
2. **TheAudioDB** (Phase 2) — adds music canvas
3. **Sound DNA** (Phase 3) — unique feature
4. **Tap to Identify** (Phase 3) — Shazam-like feature
5. **Enhanced Search** (Phase 4) — better search with wolfXspotify
6. **YouTube Music** (Phase 5) — full song streaming
7. **Gamification** (Phase 6) — engagement
8. **Social** (Phase 6) — viral growth
