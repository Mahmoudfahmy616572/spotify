# spotify

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## Supabase Storage Migration ⚡️

This project supports Supabase Storage to replace Firebase Storage for file uploads.

**Note:** there are no files stored in Firebase Storage for this project, so a migration step is *not required*.

Quick steps:

1. Add Supabase credentials in `lib/core/config/supabase_config.dart` (set `supabaseUrl` and `supabaseAnonKey`).
2. If you need private file access, deploy `server/signed_url.js` and set `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` in the server environment; the server verifies Firebase ID tokens and returns signed URLs.
3. Use `SupabaseStorageService` in `lib/data/sources/supabase_storage_service.dart` to upload files and get URLs.
4. Remove `firebase_storage` dependency and tighten Firebase Storage rules (or delete the bucket) after you finish migrating files.

Security notes:
- Do NOT commit your Supabase service_role key.
- Prefer generating signed URLs on the server for private files.

Files added:
- `lib/core/config/supabase_config.dart` (fill in your keys)
- `lib/data/sources/supabase_storage_service.dart` (client upload helper)
- `server/signed_url.js` (example server to create signed URLs)

Local development (.env):
- Add `flutter_dotenv` and create a `.env` file (add `.env` to `.gitignore`) with your dev keys:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

- The app loads `.env` automatically in `main.dart` (development). For production, prefer passing secrets at build time with `--dart-define`.

