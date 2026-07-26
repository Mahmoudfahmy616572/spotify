# Soundora API Architecture

## Primary API: Deezer Public API (FREE)
- **Base URL**: https://api.deezer.com/2.0
- **No API key required** for basic usage
- **Features**:
  - Search songs/albums/artists
  - Chart data (top tracks per country)
  - Album art (small/medium/big/xl)
  - 30-second track previews (direct MP3 URLs)
  - Artist images & bio
  - Genre browsing
  - Playlist data
  - Album tracklists

### Key Endpoints:
```
GET /search?q={query}          → Search songs
GET /chart                    → Top charts
GET /album/{id}               → Album details + tracks
GET /artist/{id}/top?limit=50 → Artist top tracks
GET /genre/{id}/artists       → Artists by genre
GET /playlist/{id}            → Playlist tracks
GET /track/{id}               → Track metadata
GET /radio                    → Radio stations
```

## Secondary API: TheAudioDB (FREE with key)
- **Base URL**: https://www.theaudiodb.com/api/v1/json/{APIKEY}
- **Free API Key**: 123
- **Features**:
  - 🎬 MUSIC VIDEOS (mvid.php) → YouTube video IDs for artists
  - Artist fanart/images
  - Album artwork
  - Artist biography
  - Discography data

### Key Endpoints:
```
GET /mvid.php?i={artist_id}     → Music videos for artist
GET /artist.php?i={artist_id}   → Artist details + images
GET /album.php?i={album_id}     → Album artwork
GET /search.php?s={name}        → Search artist
GET /trending.php?s={country}   → Trending music
```

## Why This Combination:
1. Deezer = Audio streams + metadata + search + charts
2. TheAudioDB = Music videos + artist images + bios
3. Both FREE = No cost to run
4. Combined = Premium experience without premium cost
