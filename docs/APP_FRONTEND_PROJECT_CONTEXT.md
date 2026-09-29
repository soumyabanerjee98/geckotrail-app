# Gecko Trail — Mobile App Frontend Project Context

## 1. Purpose

Gecko Trail is a **mobile-only MVP** for motorcycle, adventure, and off-road riders in India.

The Flutter application is the rider/host-facing product.

There is **no public website in the MVP**.

The app must consume backend APIs and must never become the source of truth for access, payment, attendance, familiarity, recommendation points, or eligibility.

---

# 2. Core User Journey

The primary rider journey is:

```text
Open App
   ↓
Discover Trails
   ↓
Open Trail Details
   ↓
View Hosted Events
   ↓
Select Event
   ↓
Enrol & Pay
   ↓
Reach Meetup
   ↓
Mark Attendance
   ↓
Location Verification
   ↓
Participate in Hosted Ride
   ↓
Host Completes Event
   ↓
Route Becomes Available
   ↓
Open My Routes
   ↓
Navigate Route
   ↓
Complete Route
   ↓
Familiarity Increases
```

Behavioural trust journey:

```text
Join Hosted Ride
      ↓
Host Observes Behaviour
      ↓
Host Awards Recommendation Points
      ↓
Private Trust Score Changes
      ↓
Sensitive Trail Eligibility May Increase
```

---

# 3. MVP Product Principles

The app should feel like a **trusted trail-riding community**, not a GPX store.

Core principles:

- Discover curated trails.
- Join experienced/trusted hosts.
- Earn route access through real participation.
- Ride unlocked routes independently.
- Build route-specific familiarity.
- Build private behavioural trust through host recommendations.
- Protect environmentally sensitive trails.

The app should not expose protected route data before the rider has valid access.

---

# 4. MVP Screens

Recommended navigation:

```text
Auth
 ├── Login
 ├── Register
 └── Forgot Password

Main App
 ├── Home
 ├── Trails
 ├── Events
 ├── My Routes
 └── Profile

Supporting
 ├── Trail Details
 ├── Event Details
 ├── Checkout/Payment
 ├── Attendance
 ├── Ride/Navigation
 ├── Ride Summary
 ├── Route Completion
 └── Notifications
```

Hosts can have additional screens based on role:

```text
Host Dashboard
 ├── My Events
 ├── Create Event
 ├── Event Details
 ├── Participants
 ├── Attendance
 ├── Complete Event
 └── Award Recommendation Points
```

Admin/operations screens are optional in the mobile client and should not force platform-management functionality into the rider UX.

---

# 5. Authentication

The app must support authenticated sessions.

Responsibilities:

- login
- registration
- token/session persistence
- logout
- refresh token/session
- protected routes
- role-aware navigation

Do not store sensitive secrets insecurely.

The app must gracefully handle:

```text
401 Unauthorized
403 Forbidden
Expired session
Network failure
Server failure
```

---

# 6. Home Screen

The Home screen should focus on discovery and upcoming activity.

Possible sections:

- Featured trails
- Upcoming hosted events
- Recommended/eligible events
- Recently viewed trails
- My upcoming rides
- Route access updates
- Notifications

Do not build a complex social feed in MVP.

---

# 7. Trail Listing

Trail cards can show:

- trail name
- region
- distance
- estimated duration
- difficulty
- terrain
- elevation
- eco-sensitive indicator
- event availability
- access state

Access states may include:

```text
NOT_UNLOCKED
UPCOMING_EVENT
UNLOCKED
```

Do not display the protected GPX/route line to users who do not have access.

---

# 8. Trail Details

Trail details should provide enough information for a rider to decide whether the trail is suitable.

Display:

- name
- region
- description
- distance
- estimated duration
- elevation
- difficulty
- terrain
- best season
- safety information
- environmental information
- photos
- eco-sensitive status
- upcoming hosted events
- access state

If unlocked:

- navigation action
- route/map preview
- familiarity
- verified completion count

If not unlocked:

- show available hosted events
- explain that route access is earned through participation in a hosted event

Never present a direct "Buy GPX" flow.

---

# 9. Hosted Events

Event cards/details should show:

- event title
- trail
- host
- host profile
- date
- start time
- meetup location
- duration
- capacity/availability
- price
- requirements
- safety instructions
- environmental instructions
- event status

The app should make the relationship clear:

```text
Event payment → participation → route access
```

Not:

```text
Payment → GPX purchase
```

---

# 10. Enrolment + Payment

The rider selects a hosted event and proceeds to checkout.

The client may display:

- event price
- payment provider UI
- payment state
- confirmation

The client must never determine:

- final authoritative price
- payment success
- enrolment validity
- route access

After payment, refresh the backend state rather than assuming success.

Possible states:

```text
PENDING
SUCCESS
FAILED
REFUNDED
```

---

# 11. Event Attendance

Attendance is available only for an enrolled rider.

The screen should:

1. Show event information.
2. Explain the attendance window.
3. Request location permission.
4. Read current GPS position.
5. Send location to backend.
6. Show verification result.

Possible UI states:

```text
NOT_STARTED
WAITING_FOR_LOCATION
OUTSIDE_RADIUS
WITHIN_RADIUS
VERIFYING
VERIFIED
REJECTED
FLAGGED
```

The app should show useful feedback such as:

- "Move closer to the meetup point."
- "Attendance opens at 7:30 AM."
- "Attendance verified."

Do not claim that GPS alone proves participation.

---

# 12. Host Event Management

Approved hosts can:

- view their events
- create an event
- edit event before locking/publishing
- view participants
- view attendance
- start/manage event
- complete event
- mark genuine participants
- award recommendation points

The host app must clearly separate:

```text
Attendance
Participation
Recommendation
```

These are different concepts.

---

# 13. Event Completion

Host completion is a critical state transition.

After the ride:

1. Host opens event.
2. Reviews enrolled/attended riders.
3. Confirms actual participants.
4. Completes the event.
5. Backend grants route access to valid participants.
6. App refreshes the rider's route access.

The frontend must never grant access locally.

---

# 14. My Routes

"My Routes" contains trails for which the backend has granted access.

Each route can show:

- trail name
- region
- familiarity
- verified completion count
- last completed date
- navigation action

A route must disappear or become inaccessible if the backend says access is invalid/revoked.

---

# 15. Map + Navigation

Use Flutter-compatible mapping/navigation technology appropriate to the existing project.

The map must support:

- current GPS position
- protected route geometry for authorized riders
- route line
- start/end points
- camera following
- basic progress
- GPS status
- navigation controls

Offline operation can be supported where practical, but it should not unnecessarily expand MVP complexity.

### Important

Do not implement:

- speed heatmaps
- difficulty heatmaps
- advanced trail intelligence
- AI navigation
- social live tracking

in the MVP.

---

# 16. Ride Session

When a rider starts an independent route ride:

```text
START
  ↓
ACTIVE
  ↓
PAUSED / RESUMED
  ↓
COMPLETE
```

The app can collect:

- GPS coordinates
- timestamps
- accuracy
- distance
- duration

The ride session belongs to the authenticated rider.

The backend must ultimately validate completion.

The app must not allow the user to manually claim:

```text
"Route completed"
```

without backend verification.

---

# 17. Route Completion

At the end of a ride:

1. Rider stops the ride.
2. App uploads/synchronizes the ride data.
3. Backend validates the route completion.
4. Backend records the completion.
5. Familiarity is updated.
6. App refreshes the route state.

Possible UI:

```text
Uploading ride...
Verifying route...
Route completed
Familiarity updated
```

If verification fails:

```text
Ride recorded
Completion could not be verified
```

Do not falsely display a verified completion.

---

# 18. Public Familiarity

Familiarity is about experience with a **specific trail**.

Example:

```text
Himalayan Loop
5 verified rides
Highly Familiar
```

It may be shown on:

- own profile
- public rider profile
- trail details
- participant/host contexts where appropriate

Familiarity is not a safety certification.

Avoid UI language that implies:

- professional qualification
- guaranteed skill level
- guaranteed safety

---

# 19. Private Recommendation Points

Recommendation points are different from familiarity.

They represent behavioural trust observed by hosts.

They should **not** appear as:

- public points
- leaderboard
- social score
- public profile statistic

The rider may receive a generic notification such as:

> "A host has added to your recommendation record."

Do not expose detailed private scoring unnecessarily.

The backend remains authoritative.

---

# 20. Eco-Sensitive Trail Eligibility

Some trails/events require a minimum recommendation level.

The app should show:

```text
Eco-sensitive trail
Additional recommendation requirements apply.
```

If eligible:

```text
Eligible
```

If not eligible:

```text
Not currently eligible
```

The exact private recommendation score should not be exposed unless the product later explicitly decides otherwise.

The app must use backend eligibility.

Never calculate eligibility solely on the client.

---

# 21. Profile

Rider profile can contain:

- profile photo
- name
- bio
- riding experience
- bike information (optional)
- regions/trails
- unlocked routes
- verified route completions
- public familiarity
- hosted rides attended
- badges if later introduced

Do not expose recommendation points.

Host profile can contain:

- name
- photo
- bio
- riding experience
- regions
- trails hosted
- hosted event count
- verification status
- rider feedback if implemented

---

# 22. Notifications

MVP notifications can cover:

- enrolment confirmed
- payment status
- upcoming event reminder
- attendance verification
- event completion
- route access granted
- route completion verification
- recommendation update
- eco-sensitive eligibility
- cancellation/refund

Push notifications can use Firebase Cloud Messaging or the project's existing notification system.

---

# 23. State Management

Use the project's established state-management pattern if one already exists.

Keep:

- API state
- authentication state
- navigation state
- ride session state
- permission state

separate where practical.

Do not put business rules into widgets.

Prefer:

```text
UI
 ↓
Controller / ViewModel / Bloc / Provider
 ↓
Repository
 ↓
API Client
 ↓
Backend
```

The exact state-management package is an implementation decision unless already fixed by the project.

---

# 24. API Layer

Create a centralized API layer.

It should handle:

- base URL
- authentication headers
- token refresh
- request serialization
- response parsing
- API errors
- timeouts
- retries where safe

Do not make raw HTTP calls throughout UI widgets.

Suggested repository areas:

```text
authRepository
trailRepository
eventRepository
paymentRepository
attendanceRepository
routeRepository
rideRepository
familiarityRepository
notificationRepository
hostRepository
```

---

# 25. Permissions

The app may require:

- location permission
- background location if required by the navigation implementation
- notification permission
- storage/file permission only if actually necessary

Request permissions contextually.

Explain why location is needed.

Do not request unnecessary permissions during onboarding.

---

# 26. Offline / Network Handling

The ride experience should tolerate temporary network failures.

For ride tracking:

```text
GPS data
   ↓
Local buffer
   ↓
Sync when network available
   ↓
Backend verification
```

The app should clearly distinguish:

```text
Recorded locally
Synced
Verified
```

These are not the same state.

Do not mark a ride as verified merely because it was recorded locally.

---

# 27. Error Handling

Every major screen should handle:

- loading
- empty
- success
- error
- retry

Important examples:

```text
No events available
Event full
Payment failed
Attendance outside radius
Attendance window closed
Route not unlocked
Route data unavailable
GPS unavailable
Ride upload failed
Completion rejected
Network unavailable
Session expired
```

Errors should be human-readable and actionable.

---

# 28. Security Rules

The mobile app must never be trusted for:

- role
- route access
- payment status
- event capacity
- event eligibility
- attendance validity
- event participation
- familiarity
- recommendation points
- eco-sensitive eligibility

The frontend should reflect backend state, not create authoritative state.

Never hardcode secrets, payment credentials, or privileged API keys in the app.

---

# 29. Suggested Flutter Structure

```text
lib/
├── core/
│   ├── config/
│   ├── networking/
│   ├── storage/
│   ├── permissions/
│   ├── location/
│   ├── errors/
│   └── utils/
│
├── features/
│   ├── auth/
│   ├── home/
│   ├── trails/
│   ├── events/
│   ├── payments/
│   ├── attendance/
│   ├── routes/
│   ├── rides/
│   ├── familiarity/
│   ├── recommendations/
│   ├── notifications/
│   ├── profile/
│   └── host/
│
├── shared/
│   ├── widgets/
│   ├── models/
│   └── theme/
│
└── main.dart
```

Adapt this to the existing repository rather than restructuring a working application without reason.

---

# 30. UX Rules

The app should feel:

- adventurous
- trustworthy
- practical
- outdoors-oriented
- community-driven
- safety-conscious
- environmentally responsible

Avoid:

- excessive gamification
- fake urgency
- aggressive sales language
- presenting recommendation points as social status
- presenting familiarity as a skill certification
- exposing protected routes before access

---

# 31. MVP Non-Goals

Do not implement in the MVP unless explicitly requested:

- public web app
- direct GPX purchase
- GPX marketplace
- speed heatmaps
- difficulty heatmaps
- advanced analytics
- AI trail recommendations
- AI assistant
- social feed
- live rider tracking
- subscriptions
- regional passes
- all-India pass
- complex host payouts
- advanced SOS/rescue

---

# 32. Recommended Frontend Build Order

```text
01. Flutter foundation
02. Theme + navigation
03. Authentication
04. Home
05. Trail listing
06. Trail details
07. Event listing/details
08. Enrolment + payment
09. Attendance/location verification
10. Host event management
11. Event completion state
12. My Routes
13. Map + route loading
14. Ride tracking
15. Ride synchronization
16. Route completion
17. Familiarity
18. Recommendation/eligibility states
19. Notifications
20. Profile
21. Offline/network hardening
22. QA + release build
```

---

# 33. AI Agent Instructions

Before modifying Flutter code:

1. Read `PROJECT_CONTEXT_MVP.md`.
2. Read `BACKEND_PROJECT_CONTEXT.md`.
3. Read this file.
4. Read `AGENTS.md` if present. Create if it is not there.
5. Inspect existing screens, routing, networking, state management, and models.
6. Reuse existing architecture where reasonable.
7. Do not create duplicate API clients or business logic.
8. Do not implement backend rules in the client.
9. Do not invent missing product requirements.
10. Keep widgets focused on presentation.
11. Add loading/error/empty states.
12. Test location and permission edge cases.
13. Test offline ride buffering where implemented.
14. Run formatting, analysis, tests, and release builds after significant changes.
15. Keep the app buildable after every incremental change.

If the frontend appears to require a business rule not documented here, check the backend contract before implementing it locally.
