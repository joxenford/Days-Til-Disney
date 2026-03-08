# DaysTilDisney -- MVP Product Brief

**Version**: 1.0 MVP
**Date**: 2026-03-08
**Author**: Product Owner (Disney Trip Product Owner Agent)

---

## Product Vision

DaysTilDisney is a mobile app that transforms the wait before a Disney trip into part of the magic. Families create countdown timers to their park visits and build anticipation through beautiful theming, daily tips, and planning tools. The app serves first-time visitors and seasoned Annual Passholders alike, from the moment a trip is booked until the family walks through the gates.

---

## Target Personas

### 1. The Planning Parent (Primary)
- Age 28-45, books and organizes the family Disney trip
- Wants to stay organized and build excitement for the kids
- Checks the app daily as the trip approaches

### 2. The Excited Kid (Secondary)
- Age 4-12, dreams about the trip constantly
- Wants to see how many sleeps until Disney
- Loves interactive, colorful, animated content

### 3. The Tagging-Along Grandparent (Tertiary)
- Age 55-75, joins the family trip
- Wants a simple experience -- just the countdown and key info
- Needs accessible text sizes and clear navigation

---

## MVP Features (MoSCoW)

### MUST Have (MVP Launch)

**M1 -- Trip Creation & Management**
- Create a trip with: trip name, destination park/resort, start date, end date
- Support all 6 Disney resort destinations (12 theme parks):
  - Walt Disney World (Magic Kingdom, EPCOT, Hollywood Studios, Animal Kingdom)
  - Disneyland Resort (Disneyland, Disney California Adventure)
  - Tokyo Disney Resort (Tokyo Disneyland, Tokyo DisneySea)
  - Disneyland Paris (Disneyland Park, Walt Disney Studios Park)
  - Hong Kong Disneyland
  - Shanghai Disneyland
- Edit and delete trips
- Support multiple simultaneous trips
- Mark one trip as the "primary" countdown (shown on home screen)

**M2 -- Countdown Display**
- Large, beautiful countdown showing days (and hours/minutes on the final day)
- Park-themed visual treatment (castle silhouette, color palette per resort)
- Animated transitions as the number ticks down at midnight
- "TODAY!" celebration state when countdown reaches zero
- Milestone celebrations at key thresholds: 100, 50, 30, 14, 7, 3, 1, 0 days

**M3 -- Park-Themed Visual System**
- Each Disney resort gets a distinct color palette and castle/icon silhouette
- Walt Disney World: Cinderella Castle, royal blue and gold
- Disneyland: Sleeping Beauty Castle, pink and purple
- Tokyo Disney: Mix of both castles, cherry blossom pink and red
- Paris: Le Chateau de la Belle au Bois Dormant, lavender and rose
- Hong Kong: Castle of Magical Dreams, teal and gold
- Shanghai: Enchanted Storybook Castle, sapphire blue and silver
- Background gradients shift subtly with time of day (dawn, day, dusk, night)

**M4 -- Daily Disney Content**
- One piece of content per day during the countdown, drawn from a curated library
- Content types: fun fact, planning tip, trivia question, ride spotlight
- Content is contextual to the destination park
- Content gets more specific and actionable as the trip approaches
  - 90+ days: General Disney fun facts and history
  - 30-89 days: Planning tips (dining reservations, Lightning Lane strategy)
  - 7-29 days: Packing tips, what to expect, ride recommendations
  - 1-6 days: Day-of tips, what to do first, park opening strategy

**M5 -- Local Data Persistence**
- All trip data stored locally on device
- No account required for MVP
- Data survives app updates and device restarts

### SHOULD Have (Fast Follow, v1.1)

**S1 -- Packing & Planning Checklists**
- Pre-built packing list templates by destination (Florida vs. California vs. international)
- Pre-built planning timeline checklist (book dining at 60 days, etc.)
- Custom checklist items
- Check-off tracking with progress indicator

**S2 -- Widgets**
- iOS Home Screen widget (small, medium) showing countdown
- Android Home Screen widget showing countdown
- Lock screen widget on supported platforms

**S3 -- Notifications**
- Milestone push notifications (100 days!, 1 week!, Tomorrow!)
- Daily content notification ("Your Disney tip of the day")
- Planning reminder notifications (e.g., "Dining reservations open in 3 days!")

**S4 -- Sharing**
- Share countdown as a styled image to social media or messages
- Share a trip invite link so family members see the same countdown

### COULD Have (v1.2+)

**C1 -- Multi-User Shared Trips** (cloud sync, accounts)
**C2 -- Park Hours & Calendar Integration** (API integration)
**C3 -- Weather Forecast for Trip Dates** (weather API)
**C4 -- Budget Tracker**
**C5 -- Photo Memories** (attach trip photos after returning)
**C6 -- Apple Watch / Wear OS Companion**
**C7 -- Animated Character Greetings at Milestones**

### WON'T Have (Not in Scope)

- Real-time wait times (other apps do this well; we focus on pre-trip anticipation)
- In-park navigation or maps
- Ticket purchasing or booking
- Social feed or community features
- User-generated content sharing beyond personal trips

---

## Key Screens / Views

### Screen Map

```
App Launch (Splash / Animation)
  |
  v
Home Screen
  |-- Primary trip countdown (hero display)
  |-- Trip list (secondary trips as cards below)
  |-- Daily content card
  |
  +-- Trip Detail Screen
  |     |-- Full countdown display with park theming
  |     |-- Trip dates and park info
  |     |-- Daily content feed (scrollable history)
  |     |-- [v1.1] Checklist access
  |
  +-- Add/Edit Trip Screen
  |     |-- Trip name input
  |     |-- Resort/park selector (grouped by destination)
  |     |-- Date pickers (start and end)
  |     |-- Set as primary toggle
  |
  +-- Park Selector Screen
  |     |-- Visual cards for each resort destination
  |     |-- Sub-selection for individual parks within a resort
  |
  +-- Settings Screen
        |-- Theme preference (auto/light/dark)
        |-- [v1.1] Notification preferences
        |-- About / Credits
        |-- [v1.1] Data export
```

### Screen Count for MVP: 5-6 distinct screens

1. **Splash / Launch** -- Animated castle silhouette with sparkle
2. **Home** -- Primary countdown hero + trip list + daily content
3. **Trip Detail** -- Full-screen themed countdown with trip info
4. **Add/Edit Trip** -- Form for trip creation and editing
5. **Park Selector** -- Visual resort/park picker (could be inline or separate)
6. **Settings** -- Minimal for MVP

---

## Core Data Models

### Trip
```
Trip
  - id: UUID
  - name: String (e.g., "Smith Family Magic Kingdom Adventure")
  - resort: DisneyResort (enum)
  - parks: [DisneyPark] (one or more parks within the resort)
  - startDate: Date
  - endDate: Date
  - isPrimary: Boolean
  - createdAt: Date
  - updatedAt: Date
```

### DisneyResort (Enum)
```
DisneyResort
  - waltDisneyWorld
  - disneylandResort
  - tokyoDisneyResort
  - disneylandParis
  - hongKongDisneyland
  - shanghaiDisneyland
```

### DisneyPark (Enum)
```
DisneyPark
  - magicKingdom
  - epcot
  - hollywoodStudios
  - animalKingdom
  - disneyland
  - californiaAdventure
  - tokyoDisneyland
  - tokyoDisneySea
  - disneylandParkParis
  - waltDisneyStudiosPark
  - hongKongDisneylandPark
  - shanghaiDisneylandPark

  // Each park should carry metadata:
  - displayName: String
  - resort: DisneyResort
  - iconAssetName: String
  - colorPalette: ParkColorPalette
```

### ParkColorPalette
```
ParkColorPalette
  - primary: Color
  - secondary: Color
  - accent: Color
  - backgroundGradientStart: Color
  - backgroundGradientEnd: Color
  - textOnPrimary: Color
```

### DailyContent
```
DailyContent
  - id: UUID
  - type: ContentType (funFact, planningTip, trivia, rideSpotlight)
  - title: String
  - body: String
  - park: DisneyPark? (nil = applies to all parks)
  - resort: DisneyResort? (nil = applies to all resorts)
  - daysOutRange: ClosedRange<Int> (e.g., 30...89 for planning tips)
  - source: String? (attribution if needed)
```

### Milestone
```
Milestone
  - daysOut: Int (100, 50, 30, 14, 7, 3, 1, 0)
  - title: String ("100 Days of Magic!", "One Week to Go!", "TODAY!")
  - celebrationType: CelebrationType (confetti, fireworks, sparkle)
```

### UserPreferences
```
UserPreferences
  - themeMode: ThemeMode (auto, light, dark)
  - hasCompletedOnboarding: Boolean
  - notificationsEnabled: Boolean (v1.1)
  - notificationTime: Date (v1.1, default 8:00 AM)
```

---

## External Services & APIs

### MVP: None Required
The MVP is fully offline-capable. All content (daily tips, fun facts, trivia) is bundled with the app as a local JSON or embedded data source. This is a deliberate choice:
- Zero friction onboarding (no account, no network dependency)
- Fastest possible time to delight
- Simplifies the initial architecture significantly

### Post-MVP Integrations to Plan For
The architecture should use a repository/service layer pattern so these can be plugged in later:

| Service | Purpose | Timeline |
|---------|---------|----------|
| Local Notifications API | Milestone and daily content alerts | v1.1 |
| CloudKit / Firebase | Cloud sync for shared trips | v1.2 |
| Disney Park Hours API (unofficial) | Show park hours for trip dates | v1.2 |
| Weather API (OpenWeatherMap or similar) | Forecast for trip dates | v1.2 |
| WidgetKit / App Widgets | Home screen countdown widgets | v1.1 |
| StoreKit / Google Billing | Premium features (if monetized) | v1.3+ |

### Architecture Implication
Even though MVP has no network calls, the data layer should be structured with:
- A **Repository** abstraction per domain (TripRepository, ContentRepository)
- Repository implementations that start as local-only but can later add remote data sources
- A **Service** layer for any future API integrations
- Clear separation so adding CloudKit or an API does not require rewriting ViewModels

---

## User Preferences & Settings (MVP)

| Setting | Type | Default | Notes |
|---------|------|---------|-------|
| Theme mode | auto / light / dark | auto | Follows system by default |
| Onboarding completed | Boolean | false | Show onboarding on first launch |
| Primary trip ID | UUID? | nil (first trip created) | Which trip shows as hero countdown |

### Post-MVP Settings
- Notification preferences (on/off, time of day, which milestones)
- Temperature unit (Fahrenheit / Celsius) for weather integration
- Date format preference (for international users)
- Accessibility: reduced motion toggle (respects system setting by default)

---

## Disney Theming Considerations for Architecture

These are not just visual polish -- they affect how the codebase should be structured.

### 1. Theme Engine (Must Be First-Class)
The app needs a **theme engine** that can swap the entire visual feel based on the selected park/resort. This is not just a color swap -- it includes:
- Color palette (6+ colors per park)
- Castle/icon silhouette asset
- Background gradient behavior
- Potential sound effects (optional, v1.1)

**Architecture impact**: Create a `ThemeProvider` or `ParkTheme` protocol/interface that ViewModels can query. Views bind to the current theme. When the user switches their primary trip or views a different trip, the theme updates reactively.

### 2. Time-of-Day Ambient Theming
The countdown screen should subtly reflect the time of day:
- Dawn (5-8 AM): Soft pinks and oranges, sunrise gradient
- Day (8 AM - 5 PM): Bright, full park palette
- Dusk (5-8 PM): Warm golds and purples, sunset feel
- Night (8 PM - 5 AM): Deep blues and purples, stars/fireworks accents

**Architecture impact**: A `TimeOfDayProvider` that the theme engine consults. This should be injectable/testable (not hardcoded to system clock).

### 3. Milestone Celebrations
When the countdown hits a milestone (100, 50, 30, 14, 7, 3, 1, 0 days), the app should trigger a celebration moment:
- Confetti or fireworks particle animation overlay
- Special milestone card with unique messaging
- Haptic feedback

**Architecture impact**: A `MilestoneManager` that observes the countdown and emits celebration events. The View layer listens for these events and triggers animations. Keep the animation system modular so new celebration types can be added.

### 4. Content Delivery System
The daily content system needs to be smart about which content to show:
- Filter by destination park/resort
- Filter by days-out range
- Avoid repeating content for the same trip
- Handle edge cases (trip created with only 5 days left -- skip the 90-day content)

**Architecture impact**: A `ContentEngine` that takes a Trip and today's date, then selects appropriate content. Should track which content has been shown (persisted locally). This is complex enough to warrant its own service with unit tests.

### 5. Asset Organization
Each park needs its own asset set. Plan the asset catalog structure early:
```
Assets/
  Parks/
    WaltDisneyWorld/
      castle-silhouette.svg
      background-day.png
      background-night.png
      icon.png
    DisneylandResort/
      ...
    TokyoDisneyResort/
      ...
    DisneylandParis/
      ...
    HongKongDisneyland/
      ...
    ShanghaiDisneyland/
      ...
  Celebrations/
    confetti-particle.png
    firework-particle.png
    sparkle-particle.png
  Common/
    app-icon.png
    onboarding/
```

---

## MVP Success Criteria

1. A user can create a trip in under 30 seconds
2. The countdown is visually delightful and park-themed from the first interaction
3. The app delivers at least one piece of relevant daily content per trip
4. The app handles all edge cases gracefully: past dates, same-day trips, trips years away
5. Accessibility: VoiceOver/TalkBack reads the countdown and all content correctly
6. Performance: App launches to countdown in under 2 seconds
7. The app works fully offline with no account required

---

## Content Requirements for MVP

The app needs a curated content library bundled at launch. Minimum viable content:

| Content Type | Count per Resort | Total Minimum |
|-------------|-----------------|---------------|
| Fun Facts | 30 | 180 |
| Planning Tips | 20 | 120 |
| Trivia Questions | 15 | 90 |
| Ride Spotlights | 10 | 60 |

**Total: ~450 pieces of content minimum for MVP**

This content will be authored separately and bundled as a JSON file in the app. The data model and content engine should be built first; the content itself can be populated in parallel with development.

---

## Summary for the Mobile Dev Expert

When scaffolding the project, plan for these architectural components:

1. **Data Layer**: Trip model, DisneyPark/Resort enums with metadata, UserPreferences, DailyContent model
2. **Persistence**: Local storage (SwiftData on iOS, Room on Android) with repository abstractions
3. **Theme Engine**: ParkTheme system that drives colors, assets, and gradients per park, with time-of-day awareness
4. **Content Engine**: Service that selects and tracks daily content delivery
5. **Milestone Manager**: Observes countdowns and emits celebration events
6. **MVVM ViewModels**: HomeViewModel, TripDetailViewModel, AddEditTripViewModel, SettingsViewModel
7. **Navigation**: Simple stack-based navigation (NavigationStack on iOS, NavHost on Android)
8. **Asset Structure**: Organized by park/resort with celebration assets separate
9. **Dependency Injection**: Protocol/interface-based DI for testability from day one
10. **Accessibility**: Semantic labels, dynamic type support, reduced motion support built into the foundation
