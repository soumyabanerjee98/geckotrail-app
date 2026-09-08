# Gecko Trail

Flutter mobile MVP for adventure and off-road riders in India.

## Run

```bash
cp .env.example .env   # first time only
# edit .env with your API URL and keys
flutter pub get
flutter run
```

Default `API_BASE_URL` is `http://10.0.2.2:3000` (Android emulator → host machine).

## Configure

Environment variables live in `.env` (gitignored). Start from `.env.example`.

| Variable | Purpose |
|----------|---------|
| `API_BASE_URL` | Backend origin (without `/api/v1`) |
| `RAZORPAY_KEY_ID` | Razorpay key for checkout UI |
| `GOOGLE_MAPS_API_KEY` | Optional app-level maps key reference |
| Google Maps (native) | Also set `YOUR_GOOGLE_MAPS_API_KEY` in `android/app/src/main/AndroidManifest.xml` / iOS as needed |
| Firebase | Add `google-services.json` / `GoogleService-Info.plist` for FCM |

## Architecture

See `AGENTS.md` and `APP_FRONTEND_PROJECT_CONTEXT.md`.

```text
UI → Riverpod → Repositories → Dio → /api/v1
```

## Product rules

- Backend is source of truth for access, payments, attendance, familiarity, and eligibility.
- No direct GPX purchase flow.
- Recommendation points are never shown as a public score.
