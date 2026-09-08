# Gecko Trail — Agent Instructions

## Product

Gecko Trail is a Flutter mobile MVP for motorcycle / adventure / off-road riders in India. There is no public website in the MVP.

## Source of truth

The **backend** is the only source of truth for:

- authentication and roles
- route access / entitlements
- payment success and pricing
- event capacity and eligibility
- attendance validity and participation
- familiarity and recommendation points
- eco-sensitive eligibility

The Flutter client **reflects** backend state. It must never grant access, invent eligibility, or trust client-side payment success.

## Must not implement (MVP)

- Direct GPX purchase / marketplace
- Public recommendation score or leaderboards
- Speed / difficulty heatmaps
- AI recommendations or social feed
- Live rider tracking
- Subscriptions / region passes
- Admin/operations console in the rider app

## Architecture

```text
UI → Riverpod Notifiers → Repositories → Dio ApiClient → /api/v1
```

Do not put business rules in widgets. Do not create duplicate API clients.

## Config

Copy the example env file, then edit values locally (`.env` is gitignored):

```bash
cp .env.example .env
```

| Variable | Purpose |
|----------|---------|
| `API_BASE_URL` | Backend origin (without `/api/v1`) |
| `RAZORPAY_KEY_ID` | Razorpay key for checkout UI |
| `GOOGLE_MAPS_API_KEY` | Maps key (also set native Android/iOS keys as needed) |

Loaded at startup with `flutter_dotenv` via `AppConfig.load()`.

## Context docs

Before changing product behaviour, read:

1. `PROJECT_CONTEXT_MVP.md`
2. `BACKEND_PROJECT_CONTEXT.md`
3. `APP_FRONTEND_PROJECT_CONTEXT.md`
4. This file

## Quality bar

- Loading / empty / error / retry on major screens
- Contextual location and notification permissions
- Distinguishing Recorded vs Synced vs Verified for rides
- Keep the app buildable after every incremental change
