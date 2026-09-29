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

Host and admin tooling live in this app (Profile entry points). Backend roles/entitlements remain source of truth.

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

## API surface (app)

Repositories call paths under `AppConfig.apiPrefix` (`/api/v1`) unless noted:

| Area | Methods |
|------|---------|
| Health | `GET /health` (origin root, via `ApiClient.health`) |
| Auth | `POST /auth/register`, `/login`, `/refresh`, `/logout` |
| Users | `GET` / `PATCH /users/me`, `POST /users/me/photo` (multipart avatar) |
| Hosts | `POST /hosts/apply`, `GET` / `PATCH /hosts/me`, `GET /hosts/:userId` |
| Regions | `GET /regions`, `GET /regions/:id`, `POST` / `PATCH` (ADMIN) |
| Trails | `GET /trails`, `GET /trails/:id`, `POST` / `PATCH`, `POST /trails/:id/gpx` (ADMIN) |
| Events | `GET /events`, `GET /events/:id`, `POST` / `PATCH` (HOST), enrol/attendance/start/complete/host-rating |
| Enrollments | `GET /enrollments/me`, `GET /enrollments/:id` |
| Payments | `GET /payments/me`, `POST /payments/orders`, `POST /payments/verify`, `GET /payments/:id` |
| Access | `GET /access/me/routes`, `GET /access/:trailId`, `GET /access/:trailId/route` |
| Rides / familiarity / recommendations / notifications | as listed in backend contract |
| Admin | `GET` / `POST` / `PATCH /admin/users`, `POST /admin/hosts/:id/approve`, `GET /admin/payments` |

Razorpay webhook is backend-only. Client never invents host/admin privileges.

## Context docs

Before changing product behaviour, read:

1. `PROJECT_CONTEXT_MVP.md`
2. `BACKEND_PROJECT_CONTEXT.md`
3. `APP_FRONTEND_PROJECT_CONTEXT.md`
4. `DESIGN.md` (UI tokens & screen patterns from `design/`)
5. This file

## Quality bar

- Loading / empty / error / retry on major screens
- Contextual location and notification permissions
- Distinguishing Recorded vs Synced vs Verified for rides
- Keep the app buildable after every incremental change
