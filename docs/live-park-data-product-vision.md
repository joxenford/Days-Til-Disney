# Live Park Data: Product Vision & Implementation Plan

**Date:** 2026-03-12
**Author:** Product Owner (Disney Trip Product Agent)
**Status:** Proposal
**Target Release:** v1.2 (MVP), v1.3 (Smart Features), v1.4 (Personal Stats)

---

## 1. Strategic Vision: From Countdown to Companion

Days Til Disney today is a *before-the-trip* app. The moment a family walks through the gates of Magic Kingdom, the countdown hits zero and the app goes quiet. That is the single biggest missed opportunity in the product.

Live park data transforms the app lifecycle into three acts:

| Phase | Duration | Experience |
|-------|----------|------------|
| **Act 1: Anticipation** | Months before | Countdown, daily tips, packing lists, milestones |
| **Act 2: In the Parks** | Trip dates | Live wait times, show schedules, smart suggestions |
| **Act 3: Memories** | After the trip | Trip journal, archived countdowns, ride history |

The API from ThemeParks.wiki provides free, real-time data for all 12 Disney parks worldwide with no authentication required. This is a rare opportunity to add significant value with zero ongoing API cost.

### Why This Matters for Retention

A $1.99 paid app lives or dies on word-of-mouth. A family that opens Days Til Disney 180 times during their countdown and then *also* uses it every day in the parks will recommend it to every friend planning a Disney trip. The in-park experience is the moment of highest emotional intensity — if the app is useful *there*, it becomes unforgettable.

### Differentiation: We Are Not Building a Wait Time App

This is critical. My Disney Experience, Thrill-Data, and a dozen free apps already show wait times. We cannot and should not compete on data density. Instead, we compete on:

1. **Context** — We already know which parks this family is visiting, on which days, at which resort. No setup required.
2. **Emotion** — Our design language (dark gradients, castle silhouettes, Disney Gold, glass-morphism) makes checking wait times feel like part of the magic, not a logistics chore.
3. **Curation** — Rather than showing 60+ attractions in a table, we surface what matters: low-wait highlights, upcoming shows, and smart suggestions.
4. **Continuity** — The transition from "47 days to go!" to "You're here! Space Mountain is 25 min" should feel like a natural chapter turn, not a different app.

---

## 2. API Integration: ThemeParks.wiki v1

### Endpoints We Will Use

| Endpoint | Purpose | Refresh Rate |
|----------|---------|--------------|
| `GET /v1/entity/{parkId}/live` | Wait times, ride status, show times | Every 5 min while app is foregrounded |
| `GET /v1/destinations` | One-time mapping validation at build time | Never at runtime |

### Park ID Mapping

Every `DisneyPark` enum case maps to a ThemeParks.wiki UUID:

```
magicKingdom          -> 75ea578a-adc8-4116-a54d-dccb60765ef9
epcot                 -> 47f90d2c-e191-4239-a466-5892ef59a88b
hollywoodStudios      -> 288747d1-8b4f-4a64-867e-ea7c9b27bad8
animalKingdom         -> 1c84a229-8862-4648-9c71-378ddd2c7693
disneyland            -> 7340550b-c14d-4def-80bb-acdb51d49a66
californiaAdventure   -> 832fcd51-ea19-4e77-85c7-75d5843b127c
tokyoDisneyland       -> 3cc919f1-d16d-43e0-8c3f-1dd269bd1a42
tokyoDisneySea        -> 67b290d5-3478-4f23-b601-2f8fb71ba803
disneylandParkParis   -> dae968d5-630d-4719-8b06-3d107e944401
waltDisneyStudiosPark -> ca888437-ebb4-4d50-aed2-d227f7096968
hongKongDisneylandPark -> bd0eb47b-2f02-4d4d-90fa-cb3a68988e3b
shanghaiDisneylandPark -> ddc4357c-c148-4b36-9888-07894fe75e83
```

### API Response Shape (Key Fields)

Each entity in the `liveData` array contains:

```json
{
  "id": "uuid",
  "name": "Space Mountain",
  "entityType": "ATTRACTION" | "SHOW" | "RESTAURANT",
  "status": "OPERATING" | "CLOSED" | "REFURBISHMENT",
  "queue": {
    "STANDBY": { "waitTime": 45 },
    "RETURN_TIME": { "state": "AVAILABLE", "returnStart": "...", "returnEnd": "..." },
    "PAID_RETURN_TIME": { "state": "AVAILABLE", "price": { "amount": 12, "currency": "USD" } }
  },
  "forecast": [
    { "time": "2026-03-12T10:00:00", "waitTime": 30, "percentage": 45 }
  ],
  "showtimes": [
    { "type": "Performance", "startTime": "2026-03-12T21:30:00", "endTime": "..." }
  ],
  "lastUpdated": "2026-03-12T14:32:00Z"
}
```

---

## 3. UX Design: The "Trip Day" Experience

### 3.1 The Transition Moment

When `trip.isOngoing` becomes true (today falls between startDate and endDate), the entire TripDetail screen transforms. This is the single most important UX moment in this feature.

**What changes:**

- The countdown hero switches from "47 Days" to **"Day 3 of 7"** with a progress ring showing how far through the trip they are.
- Below the hero, a new **"Today at [Park Name]"** card appears — the gateway to live data.
- The daily content card shifts from planning tips to in-park tips ("Best time to ride Seven Dwarfs Mine Train is the first 30 minutes after park open").
- The overall energy of the screen feels celebratory — you made it!

**What does NOT change:**

- The castle silhouette, gradient background, and design language remain identical. This is still Days Til Disney, not a different app.
- Trip notes, packing list, and the share button remain accessible.
- The park pills at the top of TripDetail still show all selected parks.

### 3.2 Screen: "Today at the Park" Card (TripDetail)

This is NOT a full screen — it is a card embedded in the existing TripDetail scroll view, positioned between the trip metadata and the notes section. It appears only when `trip.isOngoing` is true.

**Card Contents:**

```
+--------------------------------------------------+
|  [Park Icon]  Today at Magic Kingdom              |
|                                                    |
|  Shortest Waits Right Now                          |
|  Haunted Mansion .............. 15 min             |
|  Pirates of the Caribbean ..... 20 min             |
|  Buzz Lightyear Space Ranger .. 10 min             |
|                                                    |
|  Longest Waits (Maybe Later)                       |
|  Seven Dwarfs Mine Train ...... 90 min             |
|  TRON Lightcycle / Run ........ 75 min             |
|                                                    |
|  Next Show: Happily Ever After at 9:30 PM          |
|                                                    |
|  [See All Wait Times ->]                           |
+--------------------------------------------------+
```

**Design Details:**
- Same glass-morphism card style as DailyContentCardView (white 7% opacity background, 16pt corner radius)
- Park-themed accent color on the header (matches the park's colorPalette.primary)
- Wait time numbers in Disney Gold for quick scanning
- "See All Wait Times" navigates to the full Park Dashboard screen
- If the trip includes multiple parks, show a horizontal park picker (pill tabs) at the top of the card so families can check any of their parks

**Smart Defaults:**
- The card auto-selects the park most likely being visited today. For single-park trips, this is obvious. For multi-park WDW trips, default to the first park in their list, but allow switching.
- Show the top 3 shortest waits and top 2 longest waits. This gives the family instant actionable information: "Oh, Haunted Mansion is only 15 minutes — let's go!"

### 3.3 Screen: Park Dashboard (New Full Screen)

Accessed via "See All Wait Times" from the card, or via a new navigation route. This is the deep-dive screen for families who want to browse everything.

**New Route:** `AppRoute.parkDashboard(tripID: UUID, parkID: DisneyPark)`

**Layout:**

```
+--------------------------------------------------+
|  < Back     Magic Kingdom        [Last: 2 min ago]|
|                                                    |
|  [Park selector pills if multi-park trip]          |
|                                                    |
|  -- HIGHLIGHTS --                                  |
|  "Right Now" summary banner:                       |
|  "23 rides operating | Avg wait: 34 min"           |
|                                                    |
|  -- ATTRACTIONS --                                 |
|  Sort: [Shortest Wait] [A-Z] [Land]               |
|                                                    |
|  Space Mountain              45 min    OPERATING   |
|    [LL Return: 2:30-3:00 PM]                       |
|                                                    |
|  Haunted Mansion             15 min    OPERATING   |
|                                                    |
|  Big Thunder Mountain        CLOSED                |
|    Reopening time not available                     |
|                                                    |
|  TRON Lightcycle / Run       75 min    OPERATING   |
|    [Individual LL: $12]                             |
|                                                    |
|  -- SHOWS --                                       |
|  Happily Ever After          9:30 PM               |
|  Festival of Fantasy Parade  3:00 PM               |
|                                                    |
|  -- DINING --  (v1.3)                              |
+--------------------------------------------------+
```

**Design Decisions:**

- **Sort options** default to "Shortest Wait" because that is the most actionable view. Families standing in the park want to know "what can I do RIGHT NOW with minimal waiting?"
- **Status colors:** OPERATING = green dot, CLOSED = red dot, REFURBISHMENT = orange dot (all with text labels for accessibility)
- **Lightning Lane info** shown inline but secondary — smaller text, muted color. Not everyone uses LL, and we should not make non-LL families feel like they are missing out.
- **Paid Individual Lightning Lane pricing** shown when available (TRON, Guardians, Rise of the Resistance, etc.) — families appreciate knowing the cost before deciding.
- **"Last updated X min ago"** timestamp in the nav bar gives confidence in data freshness.
- **Pull-to-refresh** triggers an immediate API call.

### 3.4 The Home Screen During a Trip

On the HomeView, when a trip is ongoing:

- The CountdownHeroView already handles `isOngoing` / `isToday` states. We enhance it:
  - Instead of showing "0 Days", show **"You're at [Resort Name]!"** with a subtle shimmer animation
  - Below the hero text, add a single-line live teaser: **"Shortest wait right now: Buzz Lightyear (10 min)"**
  - Tapping the hero still navigates to TripDetail, where the full "Today at the Park" card lives

### 3.5 Widget Enhancement (Future: v1.3)

The existing WidgetKit infrastructure can be extended to show a "live wait time" widget during the trip. A Medium widget could show:
- "Day 3 of 7 at Magic Kingdom"
- Top 3 shortest waits
- Refreshed via WidgetKit timeline (every 15 min — iOS controls the actual refresh rate)

This is deferred to v1.3 because WidgetKit's refresh constraints make it less reliable for truly real-time data, and the in-app experience should be validated first.

---

## 4. Technical Architecture

### 4.1 New Layer: LiveParkDataService

```
Core/
  Services/
    LiveParkDataService.swift       -- API client, URLSession-based
    LiveParkDataModels.swift         -- Codable response models
    LiveParkDataCache.swift          -- In-memory cache with TTL
    ThemeParksWikiMapping.swift      -- DisneyPark -> UUID mapping
```

**Key Design Principles:**

- **Protocol-first** for testability: `LiveParkDataServiceProtocol` with a `MockLiveParkDataService` for previews and tests.
- **Injected via AppContainer** — same DI pattern as every other service in the app.
- **No persistence** — live data is ephemeral. We cache in memory with a 5-minute TTL. When the app is backgrounded and returns, we fetch fresh data.
- **Graceful degradation** — if the API is unreachable (airplane mode, API down), the card shows a friendly "No live data available right now" state with a retry button. The rest of TripDetail continues to work perfectly.

### 4.2 Data Flow

```
TripDetailView
  -> TripDetailViewModel (checks trip.isOngoing)
    -> LiveParkDataService.fetchLiveData(for: parkId)
      -> URLSession GET /v1/entity/{parkId}/live
      -> Decode into [LiveEntity]
      -> Cache result with timestamp
    -> ViewModel exposes: shortestWaits, longestWaits, nextShow, allAttractions
  -> "Today at the Park" card renders from ViewModel state
```

### 4.3 Refresh Strategy

| Scenario | Behavior |
|----------|----------|
| App foregrounded, trip ongoing | Fetch immediately, then every 5 minutes via Timer |
| App backgrounded | Stop timer, no fetches |
| App returns to foreground | Check cache age; if > 5 min, fetch fresh |
| Pull-to-refresh on Park Dashboard | Immediate fetch, reset timer |
| No network | Show cached data with "Last updated X min ago" or empty state |
| Trip not ongoing | No fetches at all — zero network overhead for countdown mode |

### 4.4 Battery & Data Considerations

- **5-minute refresh interval** is conservative. Most wait time apps refresh every 1-2 minutes. We intentionally choose 5 minutes because:
  - Wait times do not change drastically minute-to-minute
  - Families should be enjoying the parks, not staring at refresh spinners
  - Battery impact at 5-min intervals is negligible
- **Payload size** for a single park: approximately 15-30 KB per response (60-80 entities). At one fetch per 5 minutes over a 12-hour park day, that is roughly 2-4 MB total. Trivial.
- **No background fetch** — we do not use BGTaskScheduler. Data is only fetched when the app is in the foreground.

### 4.5 Offline Fallback

Disney parks have notoriously spotty cellular coverage (inside rides, in certain lands like Galaxy's Edge). The app must handle connectivity gaps gracefully:

- Display the last-cached data with a "Last updated X min ago" badge
- If cache is older than 15 minutes, show a subtle "Data may be outdated" indicator
- If no cached data exists at all, show: "Couldn't load wait times. Check your connection and pull down to refresh."
- The rest of TripDetail (countdown, notes, packing list, daily content) works fully offline as it does today

---

## 5. User Stories (MVP — v1.2)

### US-1: Today at the Park Card

**As a** family visiting Magic Kingdom today,
**I want to** see the shortest and longest wait times on my trip detail screen,
**So that** I can quickly decide what to ride next without leaving the app I have been using for months.

**Acceptance Criteria:**
- [ ] Card appears on TripDetailView only when `trip.isOngoing == true`
- [ ] Card shows the park name with its themed icon
- [ ] Card displays the 3 attractions with the shortest standby wait times (OPERATING status, waitTime > 0)
- [ ] Card displays the 2 attractions with the longest standby wait times
- [ ] Card shows the next upcoming show time (if any shows are scheduled)
- [ ] Card includes a "See All Wait Times" button that navigates to the Park Dashboard
- [ ] If the trip has multiple parks, a horizontal pill picker allows switching parks
- [ ] If no network is available, card shows a friendly offline message
- [ ] Card refreshes automatically every 5 minutes while visible
- [ ] All text uses existing DTDFont styles; card uses existing glass-morphism styling
- [ ] VoiceOver reads wait times as "Space Mountain, 45 minute wait" (not "45 min")

### US-2: Park Dashboard Screen

**As a** family in the park who wants to browse all ride options,
**I want to** see a full list of attractions with their current wait times and status,
**So that** I can plan my next move with complete information.

**Acceptance Criteria:**
- [ ] New route: `.parkDashboard(tripID: UUID, park: DisneyPark)`
- [ ] Screen header shows park name and "Last updated X min ago"
- [ ] Summary banner shows count of operating rides and average wait time
- [ ] Attractions sorted by shortest wait by default
- [ ] Sort options: Shortest Wait, A-Z, Status (operating first)
- [ ] Each attraction row shows: name, standby wait time (or status if closed), status indicator dot
- [ ] Lightning Lane return windows shown when available (secondary text)
- [ ] Individual Lightning Lane pricing shown when available
- [ ] Shows section lists all shows with their next performance time
- [ ] CLOSED and REFURBISHMENT rides shown at the bottom of the list with appropriate status styling
- [ ] Pull-to-refresh triggers immediate data fetch
- [ ] If multi-park trip, park picker pills at the top allow switching without navigating back
- [ ] Screen uses same gradient background and design language as TripDetail
- [ ] Accessibility: status indicators have text alternatives, not just color

### US-3: Trip Day Countdown Transformation

**As a** family whose Disney trip has begun,
**I want** the countdown screen to celebrate that I am here,
**So that** the app feels alive and connected to my current experience.

**Acceptance Criteria:**
- [ ] When `trip.isOngoing`, CountdownHeroView shows "Day X of Y" instead of a day count of 0
- [ ] Below the day indicator, a subtitle reads "You're at [Resort displayName]!"
- [ ] On the HomeView, a single-line teaser shows the shortest current wait from the primary park
- [ ] Tapping the hero still navigates to TripDetail
- [ ] When `trip.isToday` (first day), show "Your magic begins today!" as the subtitle
- [ ] On the last day (`trip.endDate == today`), show "Make every moment count — last day!"

### US-4: Graceful Offline Experience

**As a** family in an area of the park with poor cell service,
**I want** the app to show me the last known wait times with a clear indicator of data age,
**So that** I still have useful information even without connectivity.

**Acceptance Criteria:**
- [ ] When cached data is available but network is unreachable, show cached data
- [ ] Display "Last updated X minutes ago" with the cache timestamp
- [ ] If cache is older than 15 minutes, show an amber "Data may be outdated" badge
- [ ] If no cached data exists, show a friendly empty state with retry button
- [ ] All non-live features (notes, packing list, daily content, journal) work normally offline
- [ ] No error alerts or disruptive UI when the network is unavailable

---

## 6. User Stories (v1.3 — Smart Features)

### US-5: Hourly Wait Forecast

**As a** family planning their afternoon at EPCOT,
**I want to** see predicted wait times for the next few hours,
**So that** I can decide whether to ride Frozen Ever After now (40 min) or wait until 6 PM (predicted 20 min).

**Acceptance Criteria:**
- [ ] On the attraction detail (tap an attraction row on Park Dashboard), show hourly forecast
- [ ] Forecast displayed as a simple bar chart: time on X-axis, wait time on Y-axis
- [ ] Current hour highlighted
- [ ] If forecast data is unavailable for an attraction, section is hidden (not empty)

### US-6: Smart Suggestions

**As a** family walking around Magic Kingdom at 2 PM,
**I want** the app to suggest what to do right now based on current conditions,
**So that** I spend less time planning and more time having fun.

**Acceptance Criteria:**
- [ ] A "What to Do Right Now" section on the Park Dashboard surfaces 3 suggestions
- [ ] Suggestions are based on: shortest wait + attraction popularity + time of day
- [ ] If a show is starting within 30 minutes, it appears as a suggestion
- [ ] Suggestions refresh when wait time data refreshes
- [ ] Each suggestion shows the attraction name, current wait, and a one-line reason ("Shortest wait for a headliner" or "Show starts in 20 min")

### US-7: Show Times & Entertainment Schedule

**As a** family that does not want to miss Happily Ever After,
**I want to** see all show times for today in one place,
**So that** I can plan around the performances that matter to my family.

**Acceptance Criteria:**
- [ ] Dedicated "Shows & Entertainment" section on Park Dashboard
- [ ] Shows sorted by next performance time
- [ ] Past performances shown as dimmed/struck-through
- [ ] If a show is starting within 30 minutes, a "Starting Soon" badge appears
- [ ] Fireworks shows visually distinguished with a special icon

---

## 7. User Stories (v1.4 — Personal Stats)

### US-8: Ride Tracker

**As a** family on day 4 of our WDW trip,
**I want to** log which rides we went on each day,
**So that** I can look back and remember everything we did.

**Acceptance Criteria:**
- [ ] On the Park Dashboard, each attraction has a "Rode it!" button (checkmark)
- [ ] Tapping it logs the ride with a timestamp
- [ ] A trip summary view shows total rides per day and per park
- [ ] Ride history persists in SwiftData and syncs via iCloud
- [ ] This data enriches the Past Trip archive (Act 3 of the lifecycle)

### US-9: Personal Wait Time Stats

**As a** Disney enthusiast who loves data,
**I want to** see stats about my park day (total time waited, rides completed, busiest ride),
**So that** I can geek out about my trip efficiency.

---

## 8. Phased Release Plan

### v1.2 MVP (3-4 additional weeks beyond current v1.2 scope)

**Add to existing v1.2 Tier 1:**

| # | Feature | Effort | Impact |
|---|---------|--------|--------|
| 1 | `LiveParkDataService` + models + cache | 3 days | Foundation |
| 2 | `ThemeParksWikiMapping` (DisneyPark -> UUID) | 0.5 day | Foundation |
| 3 | "Today at the Park" card on TripDetailView | 3 days | High |
| 4 | Park Dashboard screen (full attraction list) | 4 days | High |
| 5 | Trip Day countdown transformation | 1 day | Medium |
| 6 | Offline fallback + error states | 1.5 days | Essential |
| 7 | Unit tests for service, cache, view models | 2 days | Essential |

**Total estimated effort: ~15 days (3 weeks)**

**Recommended approach:** Ship the current v1.2 (interactive widgets, Apple Watch, seasonal events) first, then add live data as a v1.2.1 or merge it into v1.2 if the submission timeline allows. Live data is a significant value-add that justifies a version bump.

### v1.3 (4-6 weeks after v1.2)

- Hourly wait forecast chart
- Smart suggestions ("What to Do Right Now")
- Full show times and entertainment schedule
- Live data in Medium widget during trip
- Restaurant status (open/closed)

### v1.4 (8-10 weeks after v1.2)

- Ride tracker with "Rode it!" logging
- Personal wait time stats
- Trip summary stats for past trip archive
- Family coordination: multiple family members see same ride log (requires Trip Sharing Phase B)

---

## 9. What Makes This Magical (Not Just Utilitarian)

This is the section that separates Days Til Disney from every other wait time app.

### 9.1 The Chapter Turn

When the countdown reaches zero, we do not just flip a switch. The transition should feel like turning a page in a storybook:

- The night before the trip, the daily content card says something like: "Tomorrow is the day. Get some sleep — you'll need your energy for [primary park]."
- On day 1, opening the app shows a brief celebration animation (reusing the existing CelebrationOverlay) with "YOUR MAGIC BEGINS TODAY" before settling into the trip-day view.
- The castle silhouette on TripDetail subtly glows brighter during the trip (increase the glow opacity from 0.55 to 0.75).

### 9.2 Contextual Warmth

Wait time numbers are cold. We warm them up:

- Instead of just "15 min", sometimes add a contextual note: "15 min — perfect for the little ones to rest their feet"
- For headliner rides with short waits, add a sparkle icon and "Great time to ride!" indicator
- When a ride goes from 60+ min down to under 20, show "Wait just dropped!" — this is genuinely useful and exciting

### 9.3 Show Time Anticipation

Shows are emotional highlights of a Disney day. Treat them differently:

- Fireworks shows get a special visual treatment — a small fireworks icon instead of the generic show icon
- A countdown-within-a-countdown: "Happily Ever After in 2 hours 15 minutes" — carrying the countdown DNA of the app into the in-park experience
- 30 minutes before a show, a subtle highlight appears on the card: "Find your spot for Happily Ever After soon!"

### 9.4 End-of-Day Wind Down

As evening approaches and the family heads back to the resort:

- The "Today at the Park" card gracefully transitions to a "Today's Recap" after park close
- "You had a magical day at Magic Kingdom" with the castle silhouette
- If ride tracking is active (v1.4), show "You went on X rides today!"
- This transitions naturally into the trip journal feature (already in v1.1)

---

## 10. Technical Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| ThemeParks.wiki API goes down | Medium | High | Cache last response, graceful fallback, no API = no crash |
| API changes response format | Low | High | Pin to v1, version-check on app launch, defensive decoding |
| API gets rate-limited or adds auth | Low | High | Our refresh rate (1 req/5 min) is very conservative; monitor |
| Poor cellular in parks | Certain | Medium | Robust offline mode with cached data and clear timestamps |
| Battery drain from frequent network | Low | Low | 5-min interval is negligible; no background fetch |
| Data accuracy (wrong wait times) | Medium | Medium | Display "Data from ThemeParks.wiki" attribution; "last updated" timestamp manages expectations |

### API Attribution

ThemeParks.wiki is a community project. We should include a small attribution in Settings: "Live park data provided by ThemeParks.wiki" with a link. This is both courteous and manages user expectations — this is community-sourced data, not official Disney data.

---

## 11. MoSCoW Summary

### Must Have (v1.2)
- LiveParkDataService with in-memory cache
- DisneyPark to ThemeParks.wiki UUID mapping
- "Today at the Park" card on TripDetailView (top 3 shortest, top 2 longest, next show)
- Park Dashboard screen (full ride list, sort by wait, status indicators)
- Trip day countdown transformation ("Day X of Y")
- Offline fallback with timestamp
- API attribution in Settings

### Should Have (v1.2 if time permits)
- Multi-park picker on the card and dashboard
- Lightning Lane return time display
- Individual Lightning Lane pricing display
- Pull-to-refresh on Park Dashboard

### Could Have (v1.3)
- Hourly wait forecast chart
- Smart suggestions
- Full show schedule
- "Wait just dropped!" alerts
- Live widget during trip
- Restaurant status

### Won't Have (for now)
- Push notifications for wait time drops (requires server infrastructure)
- Real-time map with ride locations (massive scope, not our differentiator)
- Crowd calendar predictions (complex, many competitors do this)
- Ride review or ratings (not our lane)
- Android (still deferred until iOS PMF)

---

## 12. Open Questions for Discussion

1. **Should live data be a v1.2.1 release or folded into v1.2?** The current v1.2 roadmap already has 3-4 weeks of work. Adding 3 more weeks makes it a 6-7 week release. Alternatively, ship v1.2 as planned, then do a fast-follow v1.2.1 focused entirely on live data. The latter gets value to users sooner (v1.2 ships on time) while keeping the live data work focused.

2. **Park selection UX for multi-park WDW trips.** A family visiting all four WDW parks over 7 days — should we try to guess which park they are at today (using location?), or always default to their first-selected park? Location permission adds friction and privacy concerns. Recommendation: default to first park, let them switch with one tap.

3. **How prominent should the live data card be during the trip?** It currently sits between trip metadata and notes on TripDetail. Should it be more prominent — perhaps replacing the countdown hero entirely during the trip? My recommendation is to keep the hero (transformed to "Day X of Y") and add the card below, maintaining the familiar layout.

4. **API stability confidence.** ThemeParks.wiki is a community project, not a commercial API. Should we build an abstraction layer that could swap to a different data source if needed? Recommendation: yes, the protocol-based service design naturally provides this. The `LiveParkDataServiceProtocol` can have multiple implementations.

---

*This document represents the product vision as of 2026-03-12. All estimates, phasing, and priorities are subject to refinement based on development velocity and user feedback from v1.1.*
