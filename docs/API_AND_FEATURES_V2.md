# Soundora 2.0 — Full API Stack + Premium Features
# الدليل الكامل للـ APIs والمميزات البريميوم

---

## PART 1: APIs (مرتبة من الأقوى للأقل)

### TIER 1 — APIs أساسية (مجانية + قوية جداً)

#### 1. Deezer Public API ⭐⭐⭐⭐⭐
- **URL**: https://api.deezer.com/2.0
- **Key**: لا يحتاج (مجاني بدون تسجيل)
- **بيديك**:
  - بحث أغاني/ألبومات/فنانين
  - Charts لكل دولة (Egypt, US, UK...)
  - Album cover بأحجام مختلفة (small/medium/big/xl)
  - 30 ثانية preview لأي أغنية (MP3 مباشر)
  - صور فنانين + Bio
  - Genre browsing
  - Tracklist الألبومات
  - Radio stations
- **ملاحظة**: الـ preview MP3 URLs مباشرة بدون CDN — يشتغل في Flutter مباشرة

#### 2. TheAudioDB ⭐⭐⭐⭐⭐
- **URL**: https://www.theaudiodb.com/api/v1/json/123/
- **Key**: مجاني `123`
- **بيديك**:
  - 🎬 **MUSIC VIDEOS** — فيديوهات يوتيوب لكل فنان (mvid.php)
  - صور Artist عالية الجودة (fanart)
  - Album artwork
  - Artist biography
  - Discography كاملة
  - Trending music
- **ملاحظة**: الـ music videos من اليوتيوب — نقدر نعمل crop للفيديو ونعمله loop في الـ player (زي Spotify Canvas)

#### 3. LRCLIB (موجود عندنا) ⭐⭐⭐⭐
- **URL**: https://lrclib.net/api/
- **Key**: مجاني
- **بيديك**:
  - Synced lyrics (LRC format)
  - Plain text lyrics
  - Cover art
  - بحث بالـ ISRC

#### 4. wolfXspotify-API ⭐⭐⭐⭐
- **URL**: https://spotify.xwolf.space/api/
- **Key**: مجاني بدون OAuth
- **بيديك**:
  - Search tracks/albums/artists/playlists
  - Full track metadata
  - Artist profile + genres
  - Artist top tracks
  - Album tracklist
  - Preview URLs
- **ملاحظة**: يجيب metadata من Spotify بدون ما تحتاج Spotify Developer Account

### TIER 2 — APIs متقدمة (مجانية أو شبه مجانية)

#### 5. Verome API (YouTube Music) ⭐⭐⭐⭐
- **URL**: https://verome-api.deno.dev/api/
- **Key**: مجاني
- **بيديك**:
  - بحث من YouTube Music
  - Streaming URLs (باستخدام Piped/Invidious proxies)
  - Synced lyrics (LRC format)
  - Radio mix تلقائي من أي أغنية
  - Charts + Trending لكل دولة
  - Top artists لكل دولة
  - Mood categories
  - Related songs
  - Autocomplete suggestions
- **ملاحظة**: مفتوح المصدر — تقدر تشغله locally كـ self-hosted

#### 6. Music I Want API ⭐⭐⭐⭐
- **URL**: https://musiciwant.com/api/
- **Key**: مجاني (100 req/day بدون تسجيل، 2000 مع مفتاح مجاني)
- **بيديك**:
  - BPM + Dynamic Range لكل أغنية
  - **Intensity Score (0-100)** — مقياس فريد للطاقة
  - Mood classification
  - **Misophonia flags** — تنبيهات لأصوات مزعجة
  - Recommended use cases (sleep, focus, running...)
  - **"Gentler" endpoint** — أغاني مشابهة بس أهدأ
  - Fingerprint (normalized 0-1 feature vector)
  - Batch lookup (100 أغنية في call واحد)
- **ملاحظة**: ده بديل Spotify Audio Features اللي اتقفل — ومفيش زيه

#### 7. AudD Music Recognition ⭐⭐⭐⭐
- **URL**: https://api.audd.io/
- **Key**: مجاني (300 request الأولى، بعدها $5/1000)
- **بيديك**:
  - **التعرف على أغنية من صوت** (زي Shazam بالظبط)
  - 160+ مليون أغنية في الداتابيز
  - Metadata كاملة: title, artist, album, release date
  - Streaming links
  - ISRC codes
- **ملاحظة**: ده اللي هيخلي الـ App يIdentify أي أغنية في ثانية

#### 8. Chosic API (Similar Songs) ⭐⭐⭐
- **URL**: https://parse.bot/marketplace/806b324e...
- **Key**: مجاني (100 credit/month)
- **بيديك**:
  - Similar songs with filters
  - Energy, Happiness, Acousticness, Popularity filters
  - Album art URLs
  - Spotify track IDs

### TIER 3 — APIs مساعدة (مجانية بالكامل)

#### 9. Last.fm API
- **Key**: مجاني (signup)
- **بيديك**:
  - Similar tracks
  - Artist top tags
  - Artist images
  - Scrobble data (إيه الأكتر استماعاً)

#### 10. MusicBrainz API
- **Key**: مجاني
- **بيديك**:
  - ISRC lookup
  - Artist metadata
  - Release group info
  - Cover art archive

---

## PART 2: Premium Features (مختلفة + برا الصندوق)

### FRESH IDEAS — مفيش حد في مصر/العربي عندها

#### 1. 🎵 "Sound DNA" — البصمة الصوتية
- كل أغنية ليها بصمة فريدة: BPM + Energy + Danceability + Mood
- المستخدم يشوف "ملفه الصوتي" — إيه الأكتر بيحبه
- "Sound Match" — لو عجبك أغنية، اضغط وهنعملك playlist بأغاني شبيهة بالظبط
- **API**: Music I Want + Deezer audio features
- **مفيش أي تطبيق عربي عنده Feature زي كده**

#### 2. 🎤 "Tap to Identify" — التعرف على أي أغنية
- المستخدم يضغط زر + يحط المايك — الـ App يIdentify الأغنية في ثانية
- يقدر يسمعها أو يحفظها أو يعملها like
- **API**: AudD (300 مجاني شهرياً كفاية)
- **زي Shazam بس جوّا التطبيق — مفيش حد عمل كده في app عربي**

#### 3. 🎬 "Music Canvas" — فيديو خلف الأغنية
- فيديو loop 5-15 ثانية بيشتغل ورا الأغنية في الـ Player
- من TheAudioDB نجيب music videos ونعمل auto-crop
- المستخدم يقدر يعمل upload فيديو custom
- **API**: TheAudioDB mvid.php endpoint
- **Spotify Canvas بس مجاناً — مفيش حد تاني في مصر**

#### 4. 🎧 "Smart DJ Mode" — DJ ذكي
- "Party Mode" — الأغاني ما تتقطعش + transitions سلسة
- "Chill Mode" — fade بطيء + أغاني هادية
- "Workout Mode" — BPM عالي + Energy عالية
- "Sleep Mode" — Progressive fade out + أغاني هادية
- **API**: Music I Want (intensity/mood) + Verome (radio mix)

#### 5. 📊 "Mood Map" — خريطة المزاج
- خريطة تفاعلية: اضغط على "Happy", "Sad", "Energetic", "Calm"
- كل نقطة عليها أغاني بتاعة الـ Mood ده
- "Journey Mode" — تبدأ من mood وتوصلك لأغاني جديدة
- **API**: Music I Want (moods) + Deezer genre

#### 6. 🏆 "Listening Quest" — رحلة الاستماع (Gamification)
- **Achievements**:
  - "Genre Explorer" — اسمعت من 10+ genres
  - "Night Owl" — اسمعت بعد منتصف الليل 10 مرات
  - "Superfan" — اسمعت Artist معين 100 مرة
  - "Playlist Master" — عملت 50 playlist
  - "Discovery King" — اسمعت 100 أغنية جديدة
  - "Streak" — اسمعت كل يوم 7 أيام متتالية
- **XP + Levels + Leaderboard** بين الأصحاب
- **مفيش أي تطبيق صوتيات في مصر عنده Gamification**

#### 7. 🎙️ "Karaoke Mode" — وضع الكاريوكي
- Lyrics بتتحرك على الشاشة synced
- Microphone input — المستخدم يغني
- Score — يقيّم الغناء (pitch accuracy)
- "Share Performance" — يبعت لأصحابه
- **API**: LRCLIB (synced lyrics) + Audio Recorder

#### 8. 🎨 "Audio Visualizer" — مرئي الصوت
- Visualizer بيتحرك مع الإيقاع real-time
- أنواع: Waveform, Bars, Circular, Abstract
- "Share as Video" — يعمل Instagram Story مع الأغنية
- **ميزة viral جداً — كل الناس هتعمل stories**

#### 9. 🌙 "Time Machine" — آلة الزمن
- "On This Day" — الأغنية اللي نزلت النهارده من سنة كذا
- "Your Decade" — أكتر أغاني اسمعتها في كل سنة
- "Nostalgia Mode" — يرجّعك لأغاني فترة معينة
- **API**: Deezer release dates + Hive local data

#### 10. 🤝 "Listening Party" — حفلة استماع
- Invite أصحابك لـ room
- الكل بيشتغل نفس الأغنية في نفس الوقت
- Chat في الـ room
- "Vibe Check" — thumbs up/down على الأغنية الحالية
- **Feature اجتماعي قوي — growth viral**

#### 11. 🧠 "AI Mood Playlist" — AI يعملك playlist
- المستخدم يقول "عايز أغاني للشغل" / "أغاني حزينة" / "أغاني للجري"
- الـ AI يعمل playlist مخصص
- **API**: Music I Want (intensity/mood filters) + Deezer

#### 12. 💡 "Song Story" — قصة الأغنية
- "Behind the Track" —.notes من الـ Artist
- Artist interviews (من YouTube)
- Album art history
- **API**: TheAudioDB (biography) + YouTube

#### 13. 📱 "Music Card" — بطاقة موسيقية
- المستخدم يختار أغنية + يكتب رسالة
- يعملها share كـ Card جميل (زي Spotify Wrapped cards)
- المستخدم التاني يسمع الأغنية من الـ Card
- **ميزة shareable — viral growth**

#### 14. 🔊 "Spatial Audio Lite" — صوت مكاني
- 3D audio effect على الأغاني
- "Immersive Mode" — يحول أي أغنية لـ spatial audio
- **Feature تقني مختلف — مفيش حد في مصر عنده**

---

## PART 3: Implementation Priority

### Phase 1 (الأساس —Week 1-2):
1. ✅ Deezer API — بحث + charts + covers + previews
2. ✅ TheAudioDB — music videos (Canvas)
3. ✅ LRCLIB — lyrics (موجود)

### Phase 2 (المميزات الأساسية — Week 3-4):
4. Sound DNA (Music I Want API)
5. Audio Visualizer + Share as Video
6. Tap to Identify (AudD API)
7. Achievement System (Gamification)

### Phase 3 (الاجتماعي — Week 5-6):
8. Listening Party
9. Music Card (Share)
10. Karaoke Mode
11. AI Mood Playlist

### Phase 4 (البريميوم — Week 7-8):
12. Smart DJ Mode
13. Mood Map
14. Time Machine
15. Spatial Audio Lite
