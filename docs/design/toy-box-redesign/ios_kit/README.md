# iOS app UI kit

A click-through recreation of Countdown to Magic in the Toy Box visual system.
Plain JS + React UMD — no build step and no in-browser Babel, so it opens straight from `file://`.

**Flow:** launch → welcome → new trip → home. From Home: trip detail → packing list, the "Next up" tile opens the milestone moment, the Tokyo row opens live wait times, and Settings switches theme. "I'll do this later" on Welcome lands on the empty state.

| File | Source of truth |
|---|---|
| `splash.js` | `Features/Splash/SplashView.swift` |
| `welcome.js` | `Features/Onboarding/WelcomeView.swift` |
| `empty.js` | `HomeView.swift` → `EmptyTripsView` |
| `addTrip.js` | `Features/AddEditTrip/AddEditTripView.swift`, `Components/ParkSelectorView.swift` |
| `home.js` | `Features/Home/HomeView.swift`, `Components/CountdownHeroView.swift`, `TripCardView.swift`, `DailyContentCardView.swift` |
| `tripDetail.js` | `Features/TripDetail/TripDetailView.swift` |
| `packingList.js` | `Features/PackingList/PackingListView.swift`, `Core/Models/DefaultPackingItems.swift` |
| `parkDashboard.js` | `Features/ParkDashboard/ParkDashboardView.swift`, `Engine/LiveParkData/ParkLiveData.swift` |
| `settings.js` | `Features/Settings/SettingsView.swift` |
| `milestone.js` | `Core/Models/Milestone.swift`, `DesignSystem/Animations/CelebrationOverlay.swift` |
| `extras.html` | `DaysTilDisneyWidget/DaysTilDisneyWidget.swift`, `Features/TripDetail/ShareCountdownCard.swift` |
| `shared.js` | standalone copies of the `components/` primitives |

The typed, documented versions of these primitives live in `components/core/` and `components/countdown/` — use those when building something new; `shared.js` exists only so this kit runs with no toolchain.

**Interactions that work:** navigation across all nine screens; park selection on New trip (at least one park always stays selected, matching `AddEditTripViewModel`) with Save disabled until valid; packing toggles that propagate to the Home tile and trip detail; wait-time re-sorting; theme switching.

**Deliberate departures from the Swift source:** no confetti/fireworks particle system on the milestone screen (the moment is carried by the full-bleed park panel), and no star field or glass material anywhere. Both are documented in the root `readme.md`.

**Data shown is representative, not live.** Wait times, Lightning Lane windows and Premier Access prices are plausible sample values in the shapes `LiveAttraction` defines. Attractions carry no land/area field in the model, so rows never show one.
