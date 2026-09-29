# Gecko Trail — Project Context

## 1. Product Overview

Gecko Trail is a digital platform for adventure, motorcycle, and off-road riders in India.

The platform helps riders:

- Discover curated trails across different regions of India.
- Understand trail difficulty, terrain, elevation, distance, and conditions.
- Unlock trails for independent riding.
- Navigate trails using a dedicated mobile application.
- Record rides and collect GPS-based riding data.
- Report difficult sections and current trail conditions.
- View community-generated trail intelligence.
- Book guided rides with experienced local captains.
- Receive discounts on guided sessions for trails they have already unlocked.
- Build a personal history of explored and completed trails.

The long-term vision is to create a **living digital map of India's adventure trails**, powered by the riders who actually ride them.

The GPX file is not the core product. The core product is the combination of:

- Curated trail discovery
- Reliable navigation
- Offline riding
- Community-generated trail intelligence
- Trail conditions
- Ride analytics
- Safety information
- Expert-guided experiences

---

# 2. Product Philosophy

The platform should follow this core loop:

**Discover → Choose how to ride → Ride → Record → Contribute → Improve trail intelligence**

Every ride should have the potential to make the platform more useful for future riders.

The system should progressively build knowledge about:

- Where riders struggle
- Which sections are technical
- How long trails actually take
- Average speeds
- Trail conditions
- Seasonal changes
- Popularity
- Completion rates
- Rider feedback

The more people ride, the better the trail information should become.

---

# 3. Target Users

## 3.1 Rider

The primary user.

A rider can:

- Discover trails.
- View trail information.
- Unlock trails or regions.
- Navigate trails.
- Record rides.
- Report difficulty.
- Report conditions.
- Upload photos.
- Rate/review trails.
- View ride history.
- Book guided sessions.
- View Trail Passport.
- Receive trail recommendations.

---

## 3.2 Captain

An experienced rider who leads guided trail sessions.

A captain can:

- Maintain a verified captain profile.
- Create guided sessions for approved trails.
- Define session date/time.
- Define meeting point.
- Define capacity.
- Define session pricing.
- Manage participants.
- Lead guided rides.
- Report trail conditions.

Captains must be approved by the platform before hosting sessions.

---

## 3.3 Trail Manager

A trusted role responsible for maintaining trail information.

A Trail Manager can:

- Create and edit trails.
- Upload GPX files.
- Manage trail metadata.
- Manage trail photos.
- Manage trail segments.
- Review trail reports.
- Publish/unpublish trails.

Permissions must be explicitly granted.

---

## 3.4 Operations

Operations users manage:

- Guided sessions.
- Bookings.
- Users.
- Captains.
- Reports.
- Payments.
- Support-related operations.

---

## 3.5 Super Admin

Has complete platform control.

Can:

- Manage all users.
- Manage roles and permissions.
- Manage regions.
- Manage trails.
- Manage captains.
- Manage guided sessions.
- Manage payments.
- Manage reports.
- Configure pricing and discounts.
- Configure platform settings.

---

# 4. Regions

The platform is organised around geographical regions.

Example:

```text
India
├── Maharashtra
├── Goa
├── Karnataka
├── Rajasthan
├── Himachal Pradesh
├── Uttarakhand
├── Kerala
└── Northeast India
```

Each region contains multiple curated trails.

A region may eventually be purchasable as a regional pass.

---

# 5. Trail Discovery

Users should be able to browse trails without purchasing access.

The public trail overview can include:

- Trail name
- Region
- General location
- Distance
- Elevation gain
- Estimated duration
- Difficulty
- Terrain
- Best season
- Photos
- Description
- Trail highlights
- Safety information
- Community rating
- Number of riders
- Recent trail conditions
- Guided session availability

The exact navigational route should not be exposed to users who do not have access.

The platform should provide enough information to help a rider decide whether a trail is appropriate without giving away protected route data.

---

# 6. Trail Access

There are two primary ways for a user to experience a trail.

## 6.1 Independent Ride

A user unlocks the trail or an applicable region pass.

After successful access is confirmed, the user can:

- Prepare the trail for offline use.
- Access navigation.
- View route geometry.
- Record the ride.
- Submit trail reports.
- View available trail intelligence.

The backend is always the source of truth for trail access.

---

## 6.2 Guided Ride

A user can book a guided session led by an approved captain.

A guided session can contain:

- Trail
- Captain
- Date
- Start time
- Meeting point
- Duration
- Capacity
- Price
- Requirements
- Description
- Status

Users book individual seats in a session.

---

# 7. Trail Unlock → Guided Session Discount

This is a core business mechanic.

If a user has already unlocked a trail, they receive a configurable discount on guided sessions for that trail.

Example:

```text
Trail unlock: ₹299

Guided session: ₹1,499

User already owns trail:

₹1,499 - applicable discount = final price
```

The discount should be calculated and validated by the backend.

The client must never be trusted to determine:

- Original price
- Discount
- Final price
- Eligibility

The discount may be permanent for the user's access to that trail unless the business rules explicitly change.

---

# 8. Trail Unlock and Region Passes

The platform can support multiple access models.

## Individual Trail

A user purchases access to one trail.

## Region Pass

A user purchases access to multiple trails in a region.

Example:

```text
Maharashtra Explorer
↓
Access to eligible Maharashtra trails
```

## Future All-India Pass

A future subscription or pass may provide access to trails across participating regions.

The architecture should allow these access models without tightly coupling access logic to a single purchase type.

---

# 9. Web Application

The web application is responsible for discovery, commerce, account management, administration, and guided-session management.

## Public Features

- Landing page
- Region discovery
- Region detail
- Trail discovery
- Trail detail
- Guided session discovery
- Captain/session detail
- Authentication

## Rider Features

- Dashboard
- Profile
- Trail access
- Region access
- Purchases
- Ride history
- Ride detail
- Guided bookings
- Trail Passport
- Reviews
- Reports
- Notifications

## Admin Features

- Region management
- Trail management
- GPX upload
- Trail segment management
- Captain management
- Guided session management
- Booking management
- User management
- Report moderation
- Payment management
- Basic analytics

The web application should not attempt to replace the mobile riding experience.

---

# 10. Mobile Application

The mobile application is the primary riding companion.

Its main responsibilities are:

- Trail navigation
- Offline maps
- GPS tracking
- Ride recording
- Ride statistics
- Difficulty reporting
- Condition reporting
- Ride synchronization

The mobile app should be optimized for use while riding.

The active riding interface should prioritize:

- Map
- Current location
- Route
- Distance
- Speed
- Ride time
- Elevation
- Progress
- Important warnings

The interface should minimize distractions and use large touch targets.

---

# 11. Offline-First Riding

Offline operation is a core requirement.

Many trails may have unreliable or no cellular connectivity.

Before a ride, the user should be able to prepare the trail:

```text
Trail
↓
Download route
↓
Download required map data
↓
Download trail metadata
↓
Download relevant safety/condition information
↓
Ready for offline ride
```

During the ride:

```text
GPS
↓
Local persistence
↓
Ride continues without internet
```

When connectivity becomes available:

```text
Local data
↓
Synchronization queue
↓
Backend
↓
Acknowledgement
↓
Mark synchronized
```

Network availability must not determine whether the user can continue recording their ride.

---

# 12. Active Ride Session

A user can have only one continuous active ride session at a time.

This prevents one account from simultaneously operating multiple active riding sessions.

The rule must be enforced server-side.

Possible states:

```text
PREPARING
READY
ACTIVE
PAUSED
COMPLETING
COMPLETED
CANCELLED
SYNCING
SYNCED
FAILED
```

The backend must reject attempts to start another active session for the same user.

The mobile application should restore an active session if the application is reopened while a ride is in progress.

---

# 13. GPS Ride Recording

During an active ride, the application may record:

- Latitude
- Longitude
- Timestamp
- Speed
- Elevation
- Accuracy
- Heading
- Current trail segment

The mobile application should persist GPS points locally before attempting synchronization.

The synchronization mechanism must be idempotent so that network retries do not create duplicate ride data.

---

# 14. Ride Summary

After completing a ride, show:

- Trail
- Distance
- Duration
- Average speed
- Maximum speed
- Elevation gain
- Completion status
- Number of difficulty reports
- Number of condition reports

The user should be able to:

- Rate the trail.
- Review the trail.
- Submit final feedback.

Local ride data should not be deleted until required synchronization has safely completed.

---

# 15. Difficulty Reporting

During an active ride, users can mark sections of a trail.

Possible categories:

- Easy
- Moderate
- Hard
- Very Hard
- Dangerous
- Mud
- Rocks
- Water Crossing
- Steep Climb
- Steep Descent
- Obstacle

Optional information:

- Comment
- Photo

The application should automatically associate the report with:

- User
- Ride session
- Trail
- Approximate location
- Timestamp
- Speed
- Elevation
- Current trail segment where available

Reports should first be stored locally and then synchronized.

---

# 16. Condition Reporting

Users can report current trail conditions.

Possible categories:

- Mud
- Water
- Landslide
- Fallen tree
- Blocked section
- Construction
- Road damage
- Closure
- Poor condition
- Good condition

Users can optionally attach photos and comments.

Reports should include:

- Trail
- Location
- Timestamp
- User
- Ride session where applicable
- Condition type
- Photo/comment

Recent condition information should be displayed prominently on trail pages.

---

# 17. Difficulty Heatmaps

The platform should aggregate community reports by trail section.

Example:

```text
KM 0 ───────────────────── KM 42

🟢 🟢 🟢 🟡 🟡 🟠 🟠 🔴 🔴 🟠 🟡 🟢
```

The system should eventually identify sections that riders consistently report as difficult.

Example:

> Most riders find KM 18–21 the most technically challenging section.

Do not assume a single user report represents the actual difficulty of a section.

The system should aggregate multiple signals.

---

# 18. Speed Heatmaps

Ride data can be aggregated by trail segment.

Example:

```text
0–5 km       26 km/h
5–10 km      23 km/h
10–15 km     18 km/h
15–18 km      9 km/h
18–25 km     14 km/h
25–35 km     21 km/h
35–42 km     27 km/h
```

This can eventually be represented visually as a speed heatmap.

Speed should not automatically be interpreted as difficulty.

Low speed may be caused by:

- Technical terrain
- Steep gradient
- Traffic
- Stops
- Viewpoints
- Trail conditions
- GPS inaccuracies

---

# 19. Trail Intelligence

The platform should progressively build structured knowledge about trails.

Potential data points include:

- Average speed
- Average completion time
- Elevation
- Gradient
- Difficulty reports
- Condition reports
- Number of riders
- Completion rate
- Number of stops
- User ratings
- Reviews
- Seasonal conditions

Eventually this can power a Trail Difficulty Score.

Possible inputs:

```text
Terrain
+
Elevation
+
Gradient
+
Historical speed
+
Difficulty reports
+
Stopping behaviour
+
Completion behaviour
+
Rider feedback
```

Complex scoring algorithms should not be implemented prematurely.

The initial architecture should simply capture the data required to build them later.

---

# 20. Trail Conditions Are Time-Sensitive

Trail information is not static.

A trail can change because of:

- Monsoon
- Rain
- Landslides
- Construction
- Road damage
- Fallen trees
- Water crossings
- Local restrictions

The platform should prioritize recent reports.

A trail can display information such as:

```text
⚠️ Updated 2 hours ago

Heavy mud between KM 18–22.
Water crossing currently active.
```

The system should retain historical conditions for analytics while clearly identifying current/recent conditions.

---

# 21. Trail Segmentation

Trails should be represented as a collection of logical segments.

Example:

```text
Trail
├── Segment 1
├── Segment 2
├── Segment 3
├── Segment 4
└── Segment 5
```

Segments enable:

- Difficulty analysis
- Speed analysis
- Condition reporting
- Segment-level statistics
- Heatmaps
- Future recommendations

A report should be associated with a geographic location and, where possible, the corresponding trail segment.

---

# 22. Trail Ratings and Reviews

After completing or sufficiently experiencing a trail, users can provide:

- Overall rating
- Difficulty rating
- Trail condition rating
- Scenic value
- Technical challenge
- Navigation experience

Users may also provide a written review.

Reviews should be moderated where necessary.

---

# 23. Guided Session Marketplace

The platform should eventually support a marketplace of guided trail experiences.

Captains can create sessions for approved trails.

Users can:

- Browse sessions
- Filter by date
- View captain
- View price
- View availability
- Book a seat
- Pay
- View booking
- Cancel according to policy

The backend must enforce session capacity transactionally.

---

# 24. Captain Verification

Captains should be verified before they can host paid sessions.

Potential workflow:

```text
Captain Application
↓
Experience Verification
↓
Document/Profile Review
↓
Platform Approval
↓
Captain Account Activated
↓
Can Host Guided Sessions
```

The exact verification requirements can evolve.

---

# 25. Safety

Safety should be a core part of the product because many trails are remote.

Before riding, users may see:

- Difficulty
- Estimated duration
- Recent conditions
- Weather-related information where available
- Connectivity warning
- Required equipment
- Safety notes
- Emergency information
- Nearby exits/support points where available

The mobile application should eventually provide an SOS mechanism.

Potential capabilities:

- Share current location
- Notify captain
- Notify ride members
- Share emergency location
- Display emergency contacts

Safety features must never imply that the platform guarantees rescue or emergency response unless such services actually exist.

---

# 26. Trail Passport

Users should have a personal record of their exploration.

Example:

```text
MY TRAIL PASSPORT

Maharashtra

12 / 25 trails completed

✓ Trail 01
✓ Trail 02
✓ Trail 03
🔒 Trail 04
🔒 Trail 05
```

Possible achievements:

- Trails completed
- Regions explored
- Difficulty milestones
- Distance milestones
- Guided rides
- Special trail badges

The Trail Passport is intended to increase engagement and encourage exploration.

---

# 27. Recommendations

As the platform accumulates user data, it can recommend trails based on:

- Previous trails
- Difficulty completed
- Preferred terrain
- Regions explored
- Ride history
- User preferences
- Bike type where voluntarily provided

Example:

> You enjoyed these technical trails. Here are five similar trails within your preferred travel range.

Recommendations should be introduced after sufficient user data exists.

---

# 28. Future AI Trail Intelligence

A long-term feature may allow users to ask questions such as:

> "I'm riding this trail tomorrow. What should I expect?"

The system could use:

- Trail data
- Historical ride data
- Difficulty information
- Elevation
- Recent conditions
- Weather data
- User experience

to provide a personalized trail briefing.

This is a future capability and should not drive initial architecture unnecessarily.

---

# 29. Business Model

Potential revenue streams:

## Trail Unlock

Individual trail access.

## Region Pass

Access to multiple trails within a region.

## All-India Pass

Potential future annual subscription.

## Guided Sessions

Platform takes a commission or service fee from guided bookings.

## Premium Experiences

Potential future multi-day or specialized adventure experiences.

The platform may later explore partnerships with:

- Motorcycle manufacturers
- Riding gear brands
- Adventure operators
- Hotels
- Campsites
- Service centers
- Recovery providers

These are future opportunities, not MVP requirements.

---

# 30. Security Principles

Never trust the client for:

- User role
- Trail access
- Region access
- Purchase status
- Payment status
- Price
- Discount
- Booking availability
- Ride session ownership
- Captain permissions
- Admin permissions

All important business rules must be enforced by the backend.

Downloaded GPX files should not be considered completely secure because users can potentially copy or share files.

The platform's long-term value should therefore come from the integrated experience and continuously updated trail intelligence.

---

# 31. Technology Direction

The initial technology direction is:

## Web

- Next.js
- TypeScript
- Tailwind CSS
- Modern React architecture

## Mobile

- Flutter
- Dart

## Backend

- Node.js
- TypeScript
- Express or NestJS

## Database

- PostgreSQL
- PostGIS

## Storage

- Object storage such as AWS S3

## Caching/Infrastructure

- Redis where appropriate

Technology choices may evolve if there is a strong architectural reason.

Do not introduce unnecessary dependencies.

---

# 32. High-Level System Architecture

```text
                         ┌──────────────────┐
                         │     WEB APP      │
                         │     Next.js      │
                         └────────┬─────────┘
                                  │
                                  ▼
                         ┌──────────────────┐
                         │     BACKEND      │
                         │ Node.js/TS       │
                         └────────┬─────────┘
                                  │
                    ┌─────────────┼─────────────┐
                    ▼             ▼             ▼
             ┌────────────┐ ┌───────────┐ ┌──────────┐
             │ PostgreSQL │ │   Redis   │ │ Storage  │
             │  PostGIS   │ │           │ │   S3     │
             └────────────┘ └───────────┘ └──────────┘
                                  ▲
                                  │
                         ┌────────┴─────────┐
                         │   MOBILE APP     │
                         │     Flutter      │
                         └──────────────────┘
```

The backend is the source of truth for all business rules and shared domain data.

---

# 33. Recommended Repository Structure

The project should be separated into three applications:

```text
gecko-trail-api
gecko-trail-web
gecko-trail-mobile
```

The backend defines the shared business rules and API contracts.

The web and mobile applications consume the backend rather than independently implementing business logic.

---

# 34. Development Principles for AI Agents

AI coding agents must:

1. Read `PROJECT_CONTEXT.md` before making architectural decisions.
2. Read `AGENTS.md` before modifying code.
3. Inspect existing code before creating new abstractions.
4. Avoid unnecessary dependencies.
5. Keep business logic out of UI components.
6. Avoid duplicated business logic.
7. Keep modules/domain boundaries clear.
8. Validate all external input.
9. Never trust client-side authorization.
10. Never hardcode secrets.
11. Keep the application buildable after changes.
12. Run formatting, linting, type checking, and relevant tests after implementation.
13. Prefer incremental implementation over generating the entire application at once.
14. Document significant architectural decisions.
15. Do not silently invent product requirements.

---

# 35. MVP Scope

The first release should focus on validating the core product.

Start with one region and a limited number of high-quality trails.

## Web MVP

- Authentication
- Region discovery
- Trail catalogue
- Trail detail
- Trail unlocking
- Payment
- User dashboard
- Ride history
- Admin panel
- GPX management

## Mobile MVP

- Authentication
- Unlocked trails
- Trail detail
- Offline route preparation
- Offline map/navigation
- GPS tracking
- Ride session
- Start/pause/resume/complete
- Difficulty reporting
- Condition reporting
- Ride summary
- Synchronization

## Backend MVP

- Authentication
- Users
- Roles
- Regions
- Trails
- Trail segments
- Trail access
- Purchases
- Ride sessions
- GPS tracks
- Difficulty reports
- Condition reports
- Basic analytics

Guided sessions can be implemented after the independent riding workflow is validated, unless early market validation specifically requires them.

---

# 36. Future Product Roadmap

## Phase 1 — Core Gecko Trail

- Trail discovery
- Trail access
- Navigation
- Ride recording
- Offline operation

## Phase 2 — Trail Intelligence

- Difficulty heatmaps
- Speed heatmaps
- Condition reports
- Trail ratings
- Trail reviews
- Trail Passport
- Badges

## Phase 3 — Guided Experiences

- Captain onboarding
- Captain verification
- Guided sessions
- Booking
- Payments
- Unlock discounts
- Group management

## Phase 4 — Intelligence & Personalization

- Trail recommendations
- Personalized difficulty
- AI trail briefings
- Weather-aware recommendations
- Advanced trail scoring
- Bike-specific recommendations

---

# 37. Product Flywheel

The long-term product loop is:

```text
Discover Trail
      ↓
Unlock OR Book Captain
      ↓
Ride Trail
      ↓
Record Ride
      ↓
Report Difficulty
      ↓
Report Conditions
      ↓
Generate Trail Intelligence
      ↓
Improve Trail Information
      ↓
Increase Rider Trust
      ↓
More Riders
      ↓
More Ride Data
      ↓
Better Trail Intelligence
```

This flywheel is central to the product strategy.

---

# 38. Core Product Positioning

The platform should not be positioned as simply:

> "A place to download GPX files."

Instead, position it as:

> **A trail discovery, navigation, intelligence, and guided adventure platform for riders in India.**

The long-term goal is to become:

> **A living digital map of India's adventure trails, powered by the riders who explore them.**
