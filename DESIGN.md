# Gecko Trail — Design System

Source of truth: exported frames in [`design/`](design/). This document translates those frames into tokens and UI rules for the Flutter app.

## Brand

- **Name:** GECKO TRAIL
- **Tagline:** RIDE. EXPLORE. EARN.
- **Community line:** ADVENTURE COMMUNITY OF INDIA
- **Promise:** Earn the route through hosted rides — not a GPX storefront.

Mark: white gecko silhouette on forest green (`assets/brand/app_icon.png`), generated from IconKitchen exports in `icons/`.

## Visual language

Two surface modes:

| Mode | Use | Background |
|------|-----|------------|
| **Trail light** | Auth, Home, Trails, Events, Event details, Trail details | Warm cream `#F7F4EE` with faint topo contour lines |
| **Night field** | My Routes, Profile, Ride HUD, Route completion | Near-black `#0C100E` with white / cream cards |

Motifs:

- Soft topographic contour rings (see `design/topo-motif*.png`, `design/topo-map-bg.png`)
- Orange polyline / waypoint accents for ride traces
- Large corner radius cards (16–20)
- Uppercase micro-labels for meta (`DISTANCE`, `PASSWORD`, `RIDE REQUIREMENTS`)

## Color tokens

| Token | Hex | Role |
|-------|-----|------|
| `forest` | `#1B4332` | Primary actions, active tab, headings on light |
| `moss` | `#2D6A4F` | Secondary green, verified accents |
| `ember` | `#E86A1C` | Accent: prices, links, date badges, CTA borders |
| `cream` | `#F7F4EE` | Light canvas |
| `sand` | `#E8DFD0` | Borders / chips |
| `ink` | `#141816` | Primary text on light |
| `stone` | `#6B736C` | Secondary text / labels |
| `night` | `#0C100E` | Dark canvas |
| `danger` | `#B42318` | Destructive / End Ride |
| `success` | `#1F7A4D` | Unlocked / GPS active |
| `hardBg` / `hardFg` | `#FEE2E2` / `#B42318` | HARD badge |
| `moderateBg` / `moderateFg` | `#FFEDD5` / `#C2410C` | MODERATE badge |
| `locked` | `#2A2F2C` | LOCKED badge |

## Typography

- Display / titles: **Outfit** (bold, tight tracking)
- Body / UI: **DM Sans**
- Section labels: DM Sans, 11–12px, uppercase, letter-spacing ~1.0, `stone`
- Primary button text: DM Sans SemiBold, white on `forest`

## Spacing & shape

- Screen horizontal padding: **20**
- Card radius: **16–20**
- Pill / chip radius: **999**
- Primary button: full width, height ~52, radius **14**
- Bottom nav: white bar, thin top hairline; active item `forest`, inactive `stone`

## Components

### Bottom navigation (5 tabs)

Home · Trails · Events · My Routes · Profile  
Icons: home, location pin, calendar, shield-check, person.

### Trail card (Explore Trails)

Hero image → access badge (UNLOCKED / GROUP REQUIRED / LOCKED) → region + difficulty pill → title → meta row (distance · duration · terrain). Eco leaf overlay when eco-sensitive.

### Featured trail carousel

Horizontal cards with cover, region, difficulty, title, `km • days`.

### Hosted ride card

Date block (day + month in ember) · title · host (green name) · price (ember) · spots left.

### Locked route callout

Ember-tint panel + lock icon + “Route Coordinates Locked” + link to hosted rides.

### Primary CTA

Forest fill, white label — e.g. `Sign In to Trail`, `Enroll Now — ₹3,500`, `Navigate`.

## Screen map

| Frame | File | App route / screen |
|-------|------|--------------------|
| Splash | `screen-splash.png` | Brand splash / cold start |
| Login | `screen-login.png` | `/auth/login` |
| Home | `screen-home.png` | `/home` |
| Explore Trails | `screen-trails.png` | `/trails` |
| Trail details | `screen-trail-details.png` | `/trails/:id` |
| Group ride details | `screen-event-details.png` | `/events/:id` |
| My Routes | `my-routes-content.png` | `/my-routes` |
| Profile | `profile-content.png` | `/profile` |
| Ride HUD | `hud-interface.png` | `/rides/:id/navigate` |
| Route completed | `summary-content.png` | Ride summary |
| Tab bar | `tab-bar.png` | `MainShell` |

## Motion (light)

- Soft fade on screen enter
- Horizontal featured carousel scroll
- Progress bars for familiarity (My Routes / summary)

## Do / don’t

**Do**

- Keep backend as source of truth for access, payment, attendance
- Show LOCKED / UNLOCKED from server state only
- Use cream + topo for discovery; night field for earned routes & riding

**Don’t**

- Purple gradients, glassmorphism, emoji-heavy chrome (emoji only where design shows rider greeting)
- Card soup on hero surfaces
- Client-side “unlock” without backend confirmation

## Asset usage

| Asset | Usage |
|-------|--------|
| `topo-motif*.png` | Light screen backgrounds (low opacity) |
| `topo-map-bg.png` | Splash / brand moments |
| Screen PNGs | Reference only — not bundled into the app binary by default |
