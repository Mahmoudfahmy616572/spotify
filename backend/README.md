# Soundora Audio Resolver

Small backend that searches YouTube with `yt-dlp` and returns a direct
full-length audio URL so the Flutter app can stream/download the whole track
(no more 30s Deezer previews for mainstream music).

## Endpoints

- `GET /health` → `{"status": "ok"}`
- `GET /resolve?title=<title>&artist=<artist>` →
  ```json
  {
    "videoId": "...",
    "title": "...",
    "uploader": "...",
    "duration": 248,
    "url": "https://rr1---sn...googlevideo.com/...",
    "headers": { "User-Agent": "...", "Referer": "..." }
  }
  ```
  The `url` is a direct, signed audio stream. The Flutter app streams it with
  the returned `headers`. 404 if nothing usable is found.

## Run locally

```sh
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
# try it:
curl "http://localhost:8000/resolve?title=الف+ليلة+وليلة&artist=ام+كلثوم"
```

## Deploy (free)

- **Render**: create a new Web Service → connect the repo, root directory
  `backend`, runtime `Python`, build `pip install -r requirements.txt`, start
  `uvicorn main:app --host 0.0.0.0 --port $PORT` (the `Procfile` already does).
- **Railway**: same, start command `uvicorn main:app --host 0.0.0.0 --port $PORT`.

Then put the deployed URL in the Flutter app:

```dart
// lib/core/services/youtube_resolver.dart
static const String baseUrl = String.fromEnvironment(
  'RESOLVER_URL',
  defaultValue: 'https://your-app.onrender.com',
);
```

## Notes

- Best audio (opus/m4a) is selected automatically; ExoPlayer plays it directly.
- Age-restricted/region-locked videos may fail; that's a YouTube policy issue.
- Runs a full yt-dlp extraction per `/resolve` call (~2–6s). Fine for one song
  at a time; don't batch many requests per second.
