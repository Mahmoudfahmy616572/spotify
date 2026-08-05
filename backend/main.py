"""Soundora Audio Resolver backend.

Search YouTube via yt-dlp and return a direct full-length audio URL plus the
headers needed to stream it. Used as the full-song fallback in the Flutter app.
"""

import re

import yt_dlp
from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Soundora Audio Resolver")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

_BASE_OPTS = {
    "quiet": True,
    "no_warnings": True,
    "noplaylist": True,
    "socket_timeout": 15,
    "retries": 2,
    "format": "bestaudio/best",
}

_ID_RE = re.compile(r"^[\w-]{11}$")


def _search(query: str, limit: int = 6) -> list:
    opts = {
        **_BASE_OPTS,
        "skip_download": True,
        "extract_flat": "in_playlist",
    }
    with yt_dlp.YoutubeDL(opts) as ydl:
        info = ydl.extract_info(f"ytsearch{limit}:{query}", download=False)
        return info.get("entries") or []


def _resolve(video_id: str) -> dict:
    opts = {**_BASE_OPTS, "skip_download": True}
    with yt_dlp.YoutubeDL(opts) as ydl:
        return ydl.extract_info(video_id, download=False)


def _pick_audio_url(info: dict) -> str | None:
    url = info.get("url")
    if url:
        return url
    formats = info.get("formats") or []
    for f in formats:
        acodec = f.get("acodec") or ""
        if acodec != "none" and f.get("url"):
            return f["url"]
    return None


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/resolve")
def resolve(title: str = Query(...), artist: str = ""):
    query = f"{title} {artist}".strip()
    if not query:
        raise HTTPException(status_code=400, detail="empty query")

    candidates = _search(query)
    chosen = None
    for entry in candidates:
        if not entry:
            continue
        duration = entry.get("duration") or 0
        if duration and (duration < 45 or duration > 3600):
            continue
        if entry.get("live_status") in ("is_live", "is_upcoming", "post_live"):
            continue
        chosen = entry
        break
    if chosen is None:
        raise HTTPException(status_code=404, detail="no result")

    video_id = chosen.get("id")
    if not video_id or not _ID_RE.match(video_id):
        raise HTTPException(status_code=404, detail="invalid video id")

    info = _resolve(video_id)
    url = _pick_audio_url(info)
    if not url:
        raise HTTPException(status_code=404, detail="no audio url")

    headers = info.get("http_headers") or {}
    return {
        "videoId": info.get("id"),
        "title": info.get("title"),
        "uploader": info.get("uploader"),
        "duration": info.get("duration"),
        "url": url,
        "headers": headers,
    }
