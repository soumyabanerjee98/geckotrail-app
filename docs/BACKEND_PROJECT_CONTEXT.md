# Gecko Trail — Backend Project Context

## 1. Purpose

Gecko Trail is a mobile-first trail-riding platform for motorcycle, adventure, and off-road riders in India.

The backend is the **source of truth** for authentication, trails, hosted events, payments, attendance verification, route access, route completion, familiarity, recommendation points, and eco-sensitive trail eligibility.

The Flutter mobile app is the only MVP client. It includes **rider, host, and admin** screens (host/admin entered from Profile). The client only reflects backend roles and state; it never invents privileges or unlocks.

### Current MVP business model

The MVP does **not** sell GPX files directly.

The core loop is:

```text
Discover Trail
      ↓
Find Hosted Event
      ↓
Enrol & Pay
      ↓
Attend Meetup
      ↓
Location Verification
      ↓
Participate in Event
      ↓
Host Completes Event
      ↓
Route Access Granted
      ↓
Ride Route Independently
      ↓
Complete Route Again
      ↓
Increase Public Familiarity
```

Behavioural trust loop:

```text
Participate in Hosted Ride
          ↓
Host Observes Behaviour
          ↓
Host Awards Recommendation Points
          ↓
Private Recommendation Score Increases
          ↓
Eligibility for Sensitive Trails
```

Familiarity and recommendation points are deliberately separate concepts.

---

# 2. MVP Scope

## In scope

- Rider authentication and profile
- Host onboarding and approval
- Region management
- Trail catalogue
- Trail details
- GPX upload and protected route storage
- Paid hosted events
- Event enrolment
- Payment processing
- Event capacity management
- Location-based attendance verification
- Host event completion
- Route access/entitlement
- GPX/map access for eligible riders
- GPS-based route navigation
- Route ride sessions
- Route completion verification
- Public route-specific familiarity
- Private host-awarded recommendation points
- Eco-sensitive trail eligibility
- Notifications
- Admin/operations capabilities
- Audit logging

## Explicitly out of scope for MVP

- Public website
- Direct GPX purchasing
- Speed heatmaps
- Difficulty heatmaps
- Advanced trail analytics
- AI recommendations
- Social network/feed
- Subscriptions
- Region passes
- All-India passes
- Complex host payout marketplace
- Advanced SOS/rescue platform
- Automatic behavioural scoring
- Public recommendation/reputation score

---

# 3. Roles

## Rider

Can:

- Browse listed trails
- View trail information
- Browse hosted events
- Enrol and pay
- Mark attendance when eligible
- Participate in hosted events
- Access routes earned through participation
- Navigate unlocked routes
- Complete routes
- View public familiarity for routes
- Earn private recommendation points from eligible hosts
- Enrol in eco-sensitive events when eligible

## Host

A trusted/approved rider who can lead hosted rides.

Onboarding path (backend-enforced):

```text
Rider → POST /hosts/apply → PENDING
      → Admin approve → APPROVED (+ HOST role)
      → Create/manage events → start / attendance / complete / awards
```

Can:

- Maintain host profile / application (`/hosts/me`)
- Create paid events for listed trails
- Set event date/time
- Set meetup/start point
- Set attendance radius
- Set attendance window
- Set capacity
- Set event price
- Set rider requirements
- Manage enrolled riders
- View attendance roster (`GET /events/:id/attendance`)
- Start and complete/cancel own events
- Award recommendation points to riders who genuinely participated
- Reject recommendation requests for their events

A host cannot:

- Grant route access directly (completion + participation rules do)
- Modify payment status
- Self-approve
- Award points to arbitrary users
- Award points to riders who did not participate

## Admin / Operations

Admin tooling ships inside the same Flutter app (Profile → Admin console). Backend ADMIN role is still required for all `/admin/*` and admin trail/region mutations.

Can:

- Manage users (`/admin/users`)
- Approve hosts (`POST /admin/hosts/:id/approve`) and reject via user hostStatus patch
- Create and manage regions
- Create and manage trails
- Upload and validate GPX (`POST /trails/:id/gpx`)
- Publish/unpublish trails
- Mark trails eco-sensitive
- Configure recommendation thresholds
- Review platform events / payments
- Moderate suspicious activity
- Review audit logs

---

# 4. Core Domain Entities

Recommended entities:

```text
User
HostProfile
Region
Trail
GPXAsset
TrailAccess
Event
EventEnrollment
EventAttendance
Ride
RouteCompletion
Familiarity
RecommendationPointAward
TrailEligibilityRule
Payment
Notification
AuditLog
```

Optional implementation-specific entities can be introduced only when justified.

---

# 5. Trail

A trail is the canonical route definition.

Suggested fields:

```text
id
regionId
name
slug
description
distance
estimatedDuration
elevationGain
difficulty
terrain
bestSeason
safetyInformation
environmentalInformation
ecoSensitive
recommendationThreshold
routeGeometry
gpxAssetId
coverImage
status
createdAt
updatedAt
```

Possible statuses:

```text
DRAFT
PUBLISHED
UNPUBLISHED
ARCHIVED
```

### Route protection

Users may browse trail metadata without route access.

The exact route/GPX must not be exposed through public trail APIs unless the authenticated user has valid `TrailAccess`.

---

# 6. GPX Management

Admins upload GPX files.

Backend responsibilities:

1. Validate file type and size.
2. Parse GPX.
3. Validate that a usable track exists.
4. Extract route points and metadata where useful.
5. Generate route geometry for map rendering.
6. Store original GPX securely in object storage.
7. Associate the asset with the trail.
8. Keep protected download/access URLs server-controlled.

Suggested storage:

```text
AWS S3 / compatible object storage
```

Never store sensitive/private storage credentials in the mobile app.

A signed URL can be generated only after backend authorization.

GPX protection is not DRM. A user who legitimately receives route data may technically copy it. The product's value therefore comes from the trusted community, events, navigation, access model, and familiarity/trust system.

---

# 7. Hosted Events

Hosts create paid events against existing published trails.

Suggested fields:

```text
id
trailId
hostId
title
description
startDateTime
endDateTime
meetupLatitude
meetupLongitude
attendanceRadiusMeters
attendanceStartTime
attendanceEndTime
capacity
price
currency
requirements
status
createdAt
updatedAt
```

Event statuses:

```text
DRAFT
PUBLISHED
OPEN
FULL
STARTED
COMPLETED
CANCELLED
```

The event must reference an existing trail. Hosts do not create arbitrary protected routes in the MVP.

---

# 8. Event Enrolment

Suggested fields:

```text
id
eventId
riderId
paymentId
status
enrolledAt
cancelledAt
createdAt
updatedAt
```

Possible statuses:

```text
PENDING_PAYMENT
CONFIRMED
CANCELLED
REFUNDED
ATTENDED
NO_SHOW
```

### Rules

- Capacity is enforced server-side.
- A rider cannot exceed the event's available capacity.
- Payment must be verified by the backend.
- A client must never be able to claim successful payment.
- Enrolment does not itself grant route access.
- Payment without participation does not unlock the route.

---

# 9. Payment

The payment layer should be provider-agnostic.

Suggested statuses:

```text
INITIATED
PENDING
SUCCESS
FAILED
REFUNDED
```

Suggested fields:

```text
id
userId
eventId
amount
currency
provider
providerOrderId
providerPaymentId
status
verifiedAt
createdAt
updatedAt
```

The backend must verify payment using the payment provider's server-side mechanism.

Never trust:

- client amount
- client payment status
- client transaction success
- client event price
- client discount

---

# 10. Attendance Verification

Attendance is based on multiple server-validated conditions.

A rider can mark attendance only when:

1. The rider is enrolled in the event.
2. The enrolment/payment is valid.
3. The event is within its attendance window.
4. The submitted location is sufficiently close to the configured meetup point.
5. Attendance has not already been recorded.

Suggested fields:

```text
id
eventId
riderId
latitude
longitude
accuracyMeters
verifiedDistanceMeters
verifiedAt
verificationStatus
createdAt
```

Possible statuses:

```text
VERIFIED
REJECTED
FLAGGED
```

### Important

Location is a verification signal, not absolute proof of physical participation.

Attendance alone must **not** unlock a route.

The event host must complete the event and confirm participation.

---

# 11. Participation and Route Access

Route access is an explicit backend entitlement.

Suggested `TrailAccess` fields:

```text
id
riderId
trailId
sourceEventId
grantedAt
status
```

Possible statuses:

```text
ACTIVE
REVOKED
```

### Access rule

A rider receives access only when:

```text
Valid enrolment
+ Verified attendance
+ Event completed by host
+ Rider marked as participant
= Trail access granted
```

The access operation should be idempotent.

Repeated event completion requests must not create duplicate access records.

A rider who pays but does not attend must not receive access.

A rider who attends but is marked as a no-show/non-participant must not receive access.

---

# 12. Route Completion

After route access is granted, a rider can independently ride the route.

A `Ride` records a navigation/riding session.

Suggested fields:

```text
id
riderId
trailId
startedAt
endedAt
status
startLatitude
startLongitude
endLatitude
endLongitude
distanceMeters
durationSeconds
createdAt
updatedAt
```

Possible statuses:

```text
ACTIVE
PAUSED
COMPLETED
ABANDONED
```

`RouteCompletion` should represent a backend-verified completion event.

Suggested fields:

```text
id
rideId
riderId
trailId
completedAt
verificationStatus
coveragePercentage
verifiedDistanceMeters
```

### MVP verification

Use a practical GPS-based verification approach:

- sufficient route coverage
- reasonable proximity to route geometry
- minimum meaningful movement/distance
- GPS accuracy checks
- reject obviously impossible tracks

Do not count simply opening the route as a completion.

Advanced anti-spoofing can be added later.

---

# 13. Public Familiarity

Familiarity measures how experienced a rider is with a **specific route**.

It is public.

Example:

```text
Rider A
Trail: Himalayan Loop
Verified completions: 5
Familiarity level: High
```

Recommended MVP implementation:

```text
Familiarity
-------------
riderId
trailId
verifiedCompletionCount
level
lastCompletedAt
updatedAt
```

Possible levels:

```text
NEW
FAMILIAR
EXPERIENCED
HIGHLY_FAMILIAR
```

The exact thresholds should be configurable.

### Rule

Only verified route completions increase familiarity.

A rider cannot manually edit familiarity.

---

# 14. Recommendation Points

Recommendation points represent **private behavioural trust**, not riding experience.

They are awarded by hosts based on direct observation during a hosted ride.

Relevant behaviour can include:

- safety-conscious riding
- respect for other riders
- environmental responsibility
- respect for local communities
- trail ethics
- responsible handling of sensitive terrain
- following host instructions
- responsible group behaviour

### Award rules

Only an authorized host can award recommendation points.

The backend must verify:

```text
Awarding user is an approved host
AND
Host created/led the relevant event
AND
Rider was enrolled
AND
Rider genuinely participated
AND
Event is completed
```

Suggested entity:

```text
RecommendationPointAward
-------------------------
id
riderId
hostId
eventId
points
reason
createdAt
```

Recommendation points must never be:

- self-awarded
- purchased
- transferred
- client-modified
- automatically granted for payment
- automatically granted for route completion

### Privacy

Recommendation points and the detailed recommendation score must not be exposed in public rider profiles or public APIs.

---

# 15. Eco-Sensitive Trails

A trail can be marked as eco-sensitive.

Such a trail can require a configurable recommendation-point threshold.

Example:

```text
Trail: Protected Forest Trail
Required recommendation points: 5
```

Eligibility:

```text
riderRecommendationPoints >= trail.recommendationThreshold
```

The backend must enforce this rule when the rider attempts to enrol.

The client must not be trusted to determine eligibility.

The UI can explain that additional trust/recommendation requirements apply without exposing the rider's private score.

---

# 16. API Design (authoritative Flutter client contract)

Use versioned REST under `/api/v1` (except health). The Flutter app now includes **rider + host + admin** surfaces in one mobile client. Host and admin UIs are entered from Profile; the backend remains the only authority for roles and entitlements.

Health (origin root, not under `/api/v1`):

```http
GET    /health
```

## 16.1 Auth & users

```http
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh
POST   /api/v1/auth/logout

GET    /api/v1/users/me                          # auth
PATCH  /api/v1/users/me                          # auth
```

`GET /users/me` should expose enough for Profile gating:

```text
id, email, name, photoUrl, bio, ridingExperience, bikeInfo
roles[]                    # e.g. RIDER, HOST, ADMIN
hostApproved               # boolean (optional if hostStatus present)
hostStatus                 # NONE | PENDING | APPROVED | REJECTED
hostRegions[]              # optional
```

## 16.2 Hosts (apply → approve → operate)

```http
POST   /api/v1/hosts/apply                       # auth — create/submit application
GET    /api/v1/hosts/me                          # auth — own host profile / application
PATCH  /api/v1/hosts/me                          # auth — update/resubmit application or profile
GET    /api/v1/hosts/:userId                     # optional auth
GET    /api/v1/hosts/:userId/ratings             # optional auth
```

Suggested apply / host-profile payload (Flutter Become Host screen):

```text
experienceYears
regions[]                  # regions of expertise
familiarTrails             # free text or structured later
motivation                 # marshal bio
bikeInfo
certificateFileName        # MVP: metadata only unless multipart upload is added
```

Host application statuses (align with `hostStatus` on user):

```text
NONE | PENDING | APPROVED | REJECTED
```

Rules:

- Riders apply via `POST /hosts/apply`; they cannot self-approve.
- Pending applicants may update/resubmit via `PATCH /hosts/me`.
- Only `APPROVED` hosts may call HOST-scoped event APIs.
- Admin approval is `POST /admin/hosts/:id/approve` (see §16.10).
- There is **no dedicated reject route** in the current contract; reject via `PATCH /admin/users/:id` with `hostStatus: REJECTED` (or add a dedicated reject endpoint and keep semantics identical).

Suggested `GET /hosts/me` dashboard fields (optional but used by Host Dashboard UI):

```text
status, displayName, photoUrl, ridesLed, upcomingCount, ridersLed, avgRating, regions[]
```

## 16.3 Regions

```http
GET    /api/v1/regions
GET    /api/v1/regions/:id
POST   /api/v1/regions                           # ADMIN
PATCH  /api/v1/regions/:id                       # ADMIN
```

Admin “Upload Region” UI expects create fields such as:

```text
name, stateOrTerritory, bestSeason, description, safetyNotes, terrainTypes[]
```

Cover image upload is not in the current API list; treat as future unless you add multipart.

## 16.4 Trails & GPX

```http
GET    /api/v1/trails                            # optional auth
GET    /api/v1/trails/:id                        # optional auth
GET    /api/v1/trails/:id/familiarity            # optional auth
POST   /api/v1/trails                            # ADMIN
PATCH  /api/v1/trails/:id                        # ADMIN
POST   /api/v1/trails/:id/gpx                    # ADMIN — multipart GPX
```

Admin “Upload Trail” UI expects create metadata such as:

```text
name, region / regionName / regionId
distanceKm, elevationGainM, difficulty, terrain
ecoSensitive, ecoNotes / safetyInformation
```

GPX is a separate multipart step after trail creation. Do not expose protected geometry on public `GET /trails/:id` without `TrailAccess`.

## 16.5 Events (hosted rides)

```http
GET    /api/v1/events                            # optional auth
GET    /api/v1/events/:id                        # optional auth
POST   /api/v1/events                            # HOST
PATCH  /api/v1/events/:id                        # HOST
POST   /api/v1/events/:id/enrol                  # auth
POST   /api/v1/events/:id/attendance             # auth — rider check-in
GET    /api/v1/events/:id/attendance             # HOST — roster / attendance list
POST   /api/v1/events/:id/start                  # HOST
POST   /api/v1/events/:id/complete               # HOST — confirm participants + grant access
POST   /api/v1/events/:id/host-rating            # auth — rider rates host after ride
```

Query conventions used by the Flutter client:

```text
GET /events?trailId=…     # events for a trail
GET /events?mine=true     # host’s own events (Host Dashboard)
```

Create-event payload (Create Hosted Ride UI):

```text
trailId, title, startDateTime
meetupLatitude, meetupLongitude, attendanceRadiusMeters
capacity, price, currency, requirements
```

Complete-event payload must include the participant rider IDs the host confirms (route access only for those).

`GET /events/:id/attendance` should return roster rows with enrolment + attendance signals for host management.

## 16.6 Enrollments

```http
GET    /api/v1/enrollments/me                    # auth
GET    /api/v1/enrollments/:id                   # auth
```

## 16.7 Payments

```http
GET    /api/v1/payments/me                       # auth
POST   /api/v1/payments/orders                   # auth
POST   /api/v1/payments/verify                   # auth
GET    /api/v1/payments/:id                      # auth
POST   /api/v1/payments/webhook                  # Razorpay only — never from the app
```

Client uses Razorpay **Key ID** only. Order creation, amount, and verification are backend-owned.

## 16.8 Access, rides, familiarity, recommendations, notifications

```http
GET    /api/v1/access/me/routes                  # auth — unlocked routes
GET    /api/v1/access/:trailId                   # auth — access status
GET    /api/v1/access/:trailId/route             # auth — protected route/GPX delivery

GET    /api/v1/rides/me                          # auth
POST   /api/v1/rides                             # auth
POST   /api/v1/rides/:id/complete                # auth
POST   /api/v1/rides/:id/abandon                 # auth

GET    /api/v1/familiarity/me                    # auth
GET    /api/v1/familiarity/trails/:id            # optional auth

GET    /api/v1/recommendations/me                # auth — private score summary for eligibility UX only
POST   /api/v1/recommendations/events/:id/requests              # auth
POST   /api/v1/recommendations/events/:id/awards                # HOST
POST   /api/v1/recommendations/events/:id/requests/:requestId/reject  # HOST

GET    /api/v1/notifications/me                  # auth
POST   /api/v1/notifications/device-tokens       # auth
POST   /api/v1/notifications/:id/read            # auth
```

Do **not** expose private recommendation totals on public profiles.

## 16.9 Admin

```http
GET    /api/v1/admin/users                       # ADMIN
GET    /api/v1/admin/users/:id                   # ADMIN
POST   /api/v1/admin/users                       # ADMIN
PATCH  /api/v1/admin/users/:id                   # ADMIN
POST   /api/v1/admin/hosts/:id/approve           # ADMIN
GET    /api/v1/admin/payments                    # ADMIN
```

Flutter Admin console screens (for API audit):

| Screen | Client behaviour / needed APIs |
|--------|--------------------------------|
| Admin dashboard | Derive vitals from `GET /admin/users` + `GET /trails` (or add a dedicated vitals endpoint later) |
| Host applications | List via `GET /admin/users?hostStatus=PENDING\|APPROVED\|REJECTED`; approve via `POST /admin/hosts/:id/approve`; reject via `PATCH /admin/users/:id` `{ hostStatus: REJECTED }` |
| Manage / upload trails | `GET/POST/PATCH /trails`, `POST /trails/:id/gpx` |
| Manage / upload regions | `GET/POST/PATCH /regions` |
| Manage group rides | `GET /events` (platform-wide); cancel/edit only if you expose admin event mutations |

Suggested host-application list fields (for Host Approvals cards):

```text
userId, name, photoUrl, experienceYears, regions[], motivation, bikeInfo, submittedAt, hostStatus
```

If `GET /admin/users` does not return application detail, either enrich it or have admin fetch `GET /hosts/:userId` per row.

## 16.10 API audit checklist (backend)

Use this when comparing backend OpenAPI/routes to the new mobile design:

1. **Auth bootstrap** — login/register/refresh/logout + `GET /users/me` with `roles` and `hostStatus`.
2. **Become Host** — apply / me / patch; status transitions `NONE → PENDING → APPROVED|REJECTED`.
3. **Admin host queue** — list pending applicants; approve endpoint; reject path documented and implemented.
4. **Host dashboard** — `GET /events?mine=true` (+ optional host stats on `/hosts/me`).
5. **Create / start / complete event** — HOST-only; complete grants `TrailAccess` only for confirmed participants.
6. **Attendance** — rider `POST …/attendance`; host `GET …/attendance` roster.
7. **Admin region/trail CRUD** + multipart GPX; public trail APIs never leak protected geometry.
8. **Payments** — orders/verify/webhook; webhook not callable from app.
9. **Access** — `/access/me/routes`, `/access/:trailId`, `/access/:trailId/route` (not legacy `/me/routes` names).
10. **Recommendations** — awards/requests under `/recommendations/events/...`; private `GET /recommendations/me`.
11. **Notifications** — `/notifications/me`, device-tokens, mark read.
12. **Authorization matrix** — RIDER / HOST / ADMIN enforced server-side; Flutter Profile links are convenience only.

Known client assumptions / gaps to confirm with backend:

```text
- Host reject: PATCH /admin/users/:id { hostStatus: REJECTED } (no POST …/reject)
- Host application listing: GET /admin/users?hostStatus=…
- Certificate / region cover image: metadata-only until multipart exists
- Admin platform vitals: computed client-side unless you add GET /admin/stats
- Event cancel: client may PATCH event status CANCELLED if allowed for host/admin
```

Exact JSON field names may snake_case or camelCase as long as they are consistent and documented; the Flutter parsers accept common aliases.

---

# 17. Authorization

Authorization must be server-side.

Examples:

### Rider

Can only:

- access own profile
- access own payments
- access own enrolments
- access own route entitlements
- create/manage own rides

### Host

Can only:

- manage their own events
- view participants of their own events
- complete their own events
- award recommendation points for their own completed events

### Admin

Can manage platform resources according to assigned permissions.

Never infer permissions from request body values.

---

# 18. Database

Recommended:

```text
PostgreSQL
PostGIS
```

PostGIS is useful for:

- meetup distance calculations
- route geometry
- spatial queries
- GPS verification

Suggested important indexes:

```text
User.email
Event.trailId
Event.hostId
Event.startDateTime
EventEnrollment.eventId
EventEnrollment.riderId
TrailAccess.riderId
TrailAccess.trailId
Ride.riderId
Ride.trailId
RouteCompletion.riderId
RouteCompletion.trailId
RecommendationPointAward.riderId
RecommendationPointAward.eventId
```

Use unique constraints where domain invariants require them, for example:

```text
unique(riderId, trailId) on TrailAccess
unique(riderId, trailId) on Familiarity
```

---

# 19. Storage

Use object storage such as AWS S3 for:

- GPX files
- trail images
- rider/host profile images if required

Do not expose permanent public GPX URLs.

Use authorized, short-lived signed URLs where appropriate.

---

# 20. Notifications

MVP notifications can cover:

- Event enrolment confirmation
- Payment success/failure
- Event reminders
- Attendance verification result
- Event completion
- Route access granted
- Route completion
- Eco-sensitive eligibility changes
- Recommendation point award

Push notifications can be added through Firebase Cloud Messaging or an equivalent provider.

---

# 21. Audit Logging

The following actions should be auditable:

```text
Host approval
Trail creation/update
GPX upload
Event creation/update
Enrolment
Payment state changes
Attendance verification
Event completion
Route access grant
Route completion verification
Recommendation point awards
Eligibility changes
Admin actions
```

Audit records should include:

```text
actor
action
entityType
entityId
metadata
timestamp
```

This is especially important for the trust/recommendation system.

---

# 22. Anti-Abuse

MVP should include basic protections against:

- fake attendance
- repeated attendance
- payment manipulation
- event capacity races
- duplicate route access
- fake route completion
- unauthorized recommendation awards
- excessive recommendation awards
- client-side entitlement manipulation

Do not attempt a full anti-GPS-spoofing system in the first release.

However, store enough evidence to investigate suspicious behaviour later.

---

# 23. Suggested Backend Structure

For Node.js + TypeScript:

```text
src/
├── modules/
│   ├── auth/
│   ├── users/
│   ├── hosts/
│   ├── regions/
│   ├── trails/
│   ├── gpx/
│   ├── events/
│   ├── enrollments/
│   ├── payments/
│   ├── attendance/
│   ├── access/
│   ├── rides/
│   ├── completions/
│   ├── familiarity/
│   ├── recommendations/
│   ├── notifications/
│   └── admin/
├── common/
│   ├── middleware/
│   ├── errors/
│   ├── validation/
│   ├── auth/
│   └── utils/
├── config/
├── database/
└── app.ts
```

Keep domain logic inside services/use-cases rather than controllers.

---

# 24. Recommended Implementation Order

```text
01. Project foundation
02. Authentication
03. Users + roles
04. Regions + trails
05. GPX upload/storage/parsing
06. Host approval
07. Hosted events
08. Event enrolment
09. Payments
10. Attendance verification
11. Event completion
12. Trail access
13. Mobile route delivery
14. Ride sessions
15. Route completion
16. Familiarity
17. Recommendation points
18. Eco-sensitive eligibility
19. Notifications
20. Admin/operations
21. Audit logs
22. QA + security hardening
```

Build incrementally. Keep every stage buildable.

---

# 25. Backend Non-Negotiable Rules

1. Backend is the source of truth.
2. Never trust client authorization.
3. Never trust client payment status.
4. Never unlock a route merely because payment succeeded.
5. Never unlock a route merely because attendance was submitted.
6. Route access requires verified participation and host event completion.
7. Familiarity comes only from verified route completion.
8. Familiarity is route-specific and public.
9. Recommendation points are private behavioural trust.
10. Only authorized hosts can award recommendation points.
11. Eco-sensitive eligibility is enforced server-side.
12. Do not expose private recommendation data through public APIs.
13. Do not add speed/difficulty heatmap logic to the MVP.
14. Do not build a direct GPX marketplace.
15. Keep business rules out of controllers/UI.
16. Make important state transitions auditable.
17. Use transactions for critical multi-step operations.
18. Keep secrets and provider credentials server-side.

---

# 26. AI Agent Instructions

Before changing backend code:

1. Read `PROJECT_CONTEXT_MVP.md`.
2. Read this file — especially **§16 API Design** and the **§16.10 audit checklist**.
3. Read `AGENTS.md` if present. Create if it is not there.
4. Inspect the existing implementation before adding abstractions.
5. Follow existing project conventions where they are sound.
6. Do not invent product requirements.
7. Do not move business logic into the Flutter client.
8. Treat the Flutter app’s host/admin screens as consumers of §16; prefer aligning routes/payloads to that contract over inventing parallel endpoints.
9. Validate all external input.
10. Add/update tests for business-critical rules (host approval, attendance, event completion → access, recommendation awards, eco eligibility, payments).
11. Run type checking, linting, formatting, and relevant tests.
12. Keep migrations reversible and understandable.
13. Document significant architectural decisions.

When a requirement conflicts with this document, stop and identify the conflict rather than silently changing the product model.
