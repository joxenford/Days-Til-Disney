# Handoff: Countdown to Magic — "Toy Box" visual redesign

## Overview

Countdown to Magic (iOS + Android, SwiftUI + Compose, repo `joxenford/Days-Til-Disney`) is being visually redesigned. The current build fills every screen with a four-stop park gradient, a twinkling star field, and `.ultraThinMaterial` glass cards, with ~30 SF Symbols and SF Pro Rounded throughout. The user's brief: *"it feels cheap and amateurish"* — audience is broad, "magical but grown-up", light **and** dark themes, park colour reduced to **one large panel per screen**, no photography.

The result is the **Toy Box** direction: chunky flat tiles, oversized geometric numerals, one park-coloured panel per screen, and a complete token system with theme-aware roles. It was chosen by the user from three candidate directions.

**Scope of this handoff:** the full iOS app surface (9 screens + 4 widget families + 2 share cards) and the marketing website. Android is *not* covered — only the iOS source was read.

## About the design files

Everything in this bundle is a **design reference built in HTML/CSS/JS**. They are prototypes of intended look and behaviour — **not production code to copy**. The job is to recreate them in the target codebase's own environment:

- **iOS app** → SwiftUI, in the existing `Features/` + `DesignSystem/` structure. Replace `GradientBackgroundView`, `StarFieldView` and the `.ultraThinMaterial` card treatments; extend `DTDFont` and `ParkColorPalette` rather than bypassing them.
- **Android** → Compose, mirroring whatever the iOS implementation lands on. `shared/design/color-palettes.md` remains the cross-platform source of truth; add the new semantic roles there first.
- **Website** → the existing static `website/` (plain HTML + CSS + vanilla JS). This one *can* be adapted fairly directly: same stack, same file layout.

Do not ship the `.jsx` component files. They exist to document props and states for a web audience; the app is native.

## Fidelity

**High-fidelity.** Colours, type sizes, tracking, radii, spacing and copy are final and should be matched exactly. Every value appears in `design_system/tokens/`. Two caveats:

1. **Fonts are substitutions.** The design uses **Outfit** (structure/numerals) and **Karla** (prose) because SF Pro Rounded is not redistributable for web. On iOS, ship `.system(design: .rounded)` — i.e. keep SF Pro Rounded — and treat Outfit's weights as the mapping: Outfit 800 → `.black`, 700 → `.bold`, 600 → `.semibold`. On the website, keep Outfit + Karla via Google Fonts.
2. **No logo exists.** The repo has an app icon built from a Swift `Shape` path, no wordmark. The brand renders as plain type ("Countdown to Magic", Outfit 700 / SF Rounded semibold, 19px). Nothing was invented — do not add a mark.

## The one big idea

**Each screen has exactly one park-coloured panel. Everything else is neutral.** That single rule is what separates this from the current build. Two park panels on one screen is a bug. A gradient-filled panel is a bug. A park colour used as a text colour is a bug.

Park colour appears in only three other places, all small: a 44px rounded-square swatch on secondary trip rows, the checkbox/progress fill (light theme), and full-bleed on the milestone and share cards.

## Design tokens

All values live in `design_system/tokens/*.css`. Full list there; the load-bearing ones:

### Park colours — verbatim from `Core/Models/ParkColorPalette.swift`

| Role | Light | Dark |
|---|---|---|
| Magic Kingdom | `#1A3A6B` (primary) | `#0D2545` (gradientMid1) |
| EPCOT | `#0077B6` | `#023E8A` |
| Hollywood Studios | `#C0392B` | `#7B241C` |
| Animal Kingdom | `#2E7D32` | `#1B5E20` |
| Disneyland | `#8E44AD` | `#4A148C` |
| California Adventure | `#E64A19` | `#BF360C` |
| Tokyo Disneyland | `#C62828` | `#880E4F` |
| Tokyo DisneySea | `#1565C0` | `#0D47A1` |
| Paris | `#7B1FA2` | `#4A148C` |
| Walt Disney Studios | `#D32F2F` | `#B71C1C` |
| Hong Kong | `#00796B` | `#004D40` |
| Shanghai | `#1A237E` | `#0D1757` |

**Critical:** consumers must reference a *panel role* (`--park-panel-magic-kingdom`), never the raw primary. The role resolves to the primary on light and the `-deep` variant on dark, so no call site decides the theme. In Swift, model this as a computed `panelColor(for colorScheme:)` on `ParkColorPalette` — **not** as a `if colorScheme == .dark` at each call site. Getting this wrong was the single most repeated bug during design.

### Theme-aware semantic roles

| Role | Light | Dark | Used for |
|---|---|---|---|
| `bg` | `#F3F3F1` | `#15151A` | page |
| `surface` | `#E7E7E3` | `#202028` | standard tile |
| `surface-raised` | `#FFFFFF` | `#26262E` | daily-content card, notes, packing sections |
| `surface-control` | `#E4E4E0` | `#26262E` | quiet icon buttons |
| `hairline` | `#D2D2CD` | `#2E2E38` | dividers, unchecked box border, empty progress track |
| `text-primary` | `#1B1B1F` | `#F1F1EF` | body + numerals |
| `text-muted` | `#5F5F66` | `#9A99A2` | labels, captions |
| `text-faint` | `#63636A` | `#93929B` | denominators, chevrons, disabled row names |
| `text-done` | `#6E6E75` | `#93929B` | struck-through packed items |
| `accent-interactive` | `#1A3A6B` | `#E8C84A` | toggle track, checkbox fill, progress fill |
| `on-accent` | `#FFFFFF` | `#3E3208` | glyph on that fill |
| `knob` | `#F3F3F1` | `#15151A` | switch knob |
| `gold-label` | `#7A6420` | `#E8C84A` | "TODAY'S FACT", LL/ILL meta text |
| `wait-short` | `#2E7D32` | `#4CAF50` | wait < 20 min |
| `wait-mid` | `#7A6420` | `#E8C84A` | wait < 45 min |
| `wait-long` | `#C0392B` | `#FF6B6B` | wait ≥ 45 min |

Brand accent: gold `#E8C84A` (`--gold`), deep gold `#C9A84C`, gold ink `#3E3208`. Status fills (dots/badges, surface-agnostic): operating `#4CAF50`, closed `#F44336`, refurb `#FF9800`, long wait `#FF6B6B`.

**Every text colour clears WCAG AA 4.5:1 against its own surface**, per the commitment in `shared/design/color-palettes.md`. The wait-time colours are set at **19px/700** so they qualify as large text at 3:1 — do not shrink them without darkening them.

### Typography

Two families. **Outfit** (→ SF Pro Rounded on iOS) for every structural element; **Karla** (→ `.system(design: .default)`) for sentences.

| Role | Size | Weight | Tracking | Line-height |
|---|---|---|---|---|
| Numeral, hero (home countdown) | 118 | 800 | −7 | 0.84 |
| Numeral, screen (detail, in-park) | 96 | 800 | −6 | 0.84 |
| Numeral, milestone | 172 | 800 | −12 | 0.82 |
| Numeral, stat tile | 40 | 800 | −2 | 1.0 |
| Numeral, inline (wait times) | 26 | 800 | −1 | 1.0 |
| Display (welcome headline) | 38 | 800 | −1.4 | 1.08 |
| Title (trip name on panel) | 24 | 600 | −0.4 | 1.2 |
| Heading (daily fact) | 23 | 700 | −0.4 | 1.25 |
| Body strong (buttons, row titles) | 17 | 600–700 | −0.2 | — |
| Body | 16 | 500–600 | — | — |
| Prose (Karla) | 15 | 400 | — | 1.55 |
| Caption (Karla) | 13 | 400–600 | — | — |
| Label | 12 | 700 | +1.4 uppercase | — |
| Label, loose | 12 | 700 | +2.4 uppercase | — |
| Label, small | 11 | 700 | +0.8–1.6 uppercase | — |

Denominators ("/38") are the parent numeral at half size in `text-faint`. Numerals are never centred, never outlined, never individually animated.

### Spacing

4, 6, 8, 10, **12** (gap between tiles), 14, 16, **18** (compact tile padding), **20** (screen gutter), 22, **24** (hero tile padding), 26, 30, 36. Minimum tap target 44px.

### Radii

9 checkbox · 14 icon button · 16 chip/swatch · 22 small tile · 26 tile · 30 card · 34 park panel + widget · 44 device frame · 999 pill. Nothing square; nothing sharper than 9.

### Elevation

**Flat.** No shadows anywhere in the UI — separation comes from surface steps (page → tile → raised). The only shadow in the bundle is the device frame in previews. No blur, no translucency, no material effects. Delete the existing two-layer shadow + accent bloom on `CountdownHeroView`.

## Screens

All at 390×844 (iPhone 14/15 logical). Layout is one scrolling column: 54px status spacer (fixed), then content with a 20px gutter and 12px gaps.

### 1. Launch (`splash.js` ← `SplashView.swift`)
Left-aligned, vertically centred, 40px gutter. 132×132 park panel at radius 44 with "45" (64/800/−4) bottom-aligned inside 16px padding. Below: "Countdown / to Magic" 44/800/−1.6, two lines. "Getting your trips…" in Karla 16 `text-muted`. 8px progress bar at 62%, `accent-interactive` fill on `hairline` track. Auto-advances after ~1.6s (source uses 2.2s).

### 2. Welcome (`welcome.js` ← `WelcomeView.swift`)
Top: 3×2 grid of 1:1 tiles, radius 22, 10px gap — tiles 1/3/5 filled (park navy "45", Tokyo red "7", gold "30" in gold-ink), tiles 2/4/6 plain `surface`. This replaces the old hero mark + sparkle constellation. Headline "The best part / starts early." 38/800/−1.4. Body in Karla 17/1.55. Bottom: stacked full-width buttons, radius 22, 20px padding — primary is ink fill, secondary is `surface`.

### 3. Home (`home.js` ← `HomeView.swift` + `CountdownHeroView`, `TripCardView`, `DailyContentCardView`)
Header: wordmark 19/700/−0.3 left; two 36px icon buttons right (radius 14) — "+" on ink fill, "•••" on `surface-control`.
- **Park panel**, radius 34, padding 24/26/26. Row: park name label 12/700/+1.6 at 78% white, and a "PRIMARY" pill (`rgba(255,255,255,.18)`, radius 999, 5/11 padding, 11/700). Then the numeral row: 118/800/−7 with "days" 22/600 at 82% white on the same baseline. Then trip name 24/600/−0.4. Then dates + nights in Karla 13/500 at 78%.
- **Two stat tiles**, radius 26, padding 18/20: label 12/700/+1.2 `text-muted`, numeral 40/800/−2, then either an 8px progress bar (Packed) or a Karla 13 caption (Next up). "Next up" counts to the next milestone and opens the milestone screen.
- **Daily content card** on `surface-raised`, radius 30, padding 22/24: 26px gold dot + "TODAY'S FACT" in `gold-label`, headline 23/700/−0.4, body Karla 15/1.55.
- **Trip row**, radius 26, padding 16/18: 44px park swatch (radius 16), name 17/600, meta Karla 13 `text-muted`, "›" `text-faint`. Past trips render at 60% opacity.

### 4. Empty state (`empty.js` ← `HomeView.EmptyTripsView`)
Same header. `surface` panel radius 34, padding 30/26: "00" at 96/800/−6 in `text-faint`, "Nothing to count down to — yet." 26/700/−0.6, Karla 16 body, ink button radius 20. Below, two `surface-raised` stat tiles: "PARKS 12 / across 6 resorts", "TIPS 1/day / once a trip exists".

### 5. New trip (`addTrip.js` ← `AddEditTripView.swift` + `ParkSelectorView.swift`)
Header: "Cancel" / "New trip" / "Save" (Save at 45% opacity until valid — mirrors `AddEditTripViewModel.form.isValid`).
- Name card on `surface-raised`, radius 26: label + value 22/700/−0.4 with an `accent-interactive` caret.
- Two date cards side by side, same treatment, 22/700/−0.5.
- **Resort panel** in park colour, radius 30, padding 20: resort name 17/700 + "SELECTED" pill, location/park-count Karla 13, then one row per park at radius 16 — selected rows get `rgba(255,255,255,.16)` fill with a white 20px check box (radius 7, park-coloured ✓); unselected get a 1.5px `rgba(255,255,255,.35)` border. First selected park is tagged "THEME" (it drives `Trip.primaryPark`). **At least one park always stays selected.**
- Other resorts as `surface` pills, radius 999, 10/16 padding.
- "Primary countdown" row with a 50×30 switch (knob 24px, 3px inset).

### 6. Trip detail (`tripDetail.js` ← `TripDetailView.swift`)
Back button + "Share"/"Edit" text buttons (36px tall, radius 14, `surface-control`). Park panel with the 96/800/−6 numeral, trip name 22/600, and park chips (`rgba(255,255,255,.18)`, radius 999). Three small metric tiles (START / END / NIGHTS, radius 22, value 20/700). Packing row on `surface-raised` with an inline progress bar and "12 of 38". Notes card with a gold dot when notes exist. Tips list with day-offset badges ("30d", "14d") on ink pills.

### 7. Packing list (`packingList.js` ← `PackingListView.swift`, `DefaultPackingItems.swift`)
Summary panel in park colour, radius 30: "12/38" at 64/800/−4 (denominator 28 at 70% white), "26 to go" Karla 14, then a 10px gold progress bar on `rgba(255,255,255,.22)`.
Category cards on `surface-raised`, radius 26: category label 12/700/+1.4 + "3/8" count, then rows with a 24px check box (radius 9) — checked = `accent-interactive` fill + `on-accent` ✓ + label in `text-done` with strikethrough; unchecked = 2px `hairline` border. Item names come from `DefaultPackingItems` verbatim. Footer row: "+ Add your own item".

### 8. Park dashboard (`parkDashboard.js` ← `ParkDashboardView.swift`, `ParkLiveData.swift`)
Park selector pills (selected = ink fill). Summary panel in the park's **deep** tone, radius 30: three stats at 34/800/−1.5 (OPEN / AVG MIN / SHORTEST). Sort pills (active = gold fill, gold-ink text). Attraction rows on `surface`, radius 22, padding 16/18: name 16/600, optional meta Karla 12, and a wait pill at 19/700 in the `wait-*` colour on a 6% neutral wash. Non-operating rows: name in `text-faint` + a neutral "REFURB"/"CLOSED" chip at 11/700.

**Only render fields `LiveAttraction` actually has:** `name`, `status`, `standbyWaitMinutes` (null → "Walk-on"), `lightningLaneReturnWindow.displayString`, `paidLightningLanePrice.displayPrice`, `lastUpdated`. **There is no land/area field** — do not add one.

### 9. Settings (`settings.js` ← `SettingsView.swift`)
Appearance card with a 3-way segmented control (Light / Dark / System — active = ink fill, radius 14). Two toggle rows (iCloud sync, milestone notifications) with title 16/600 + Karla 13 subtitle. About card with hairline-divided rows (Version 1.0.0 (1) / Privacy policy / Support). Then the legal line in Karla 13 `text-muted`, verbatim: "Countdown to Magic is an unofficial app. Not affiliated with, endorsed by, or sponsored by The Walt Disney Company."

### 10. Milestone (`milestone.js` ← `Milestone.swift`, `CelebrationOverlay.swift`)
Full-bleed park panel, no status spacer. "MILESTONE · MAGIC KINGDOM" 12/700/+2.4. Numeral 172/800/−12. Title in gold 40/800/−1.4 over two lines. Body Karla 17/1.55. Then an **8-segment strip** — one per `Milestone.all` threshold (100, 50, 30, 14, 7, 3, 1, 0), passed ones gold, remaining at 28% white — with the caption "3 of 8 milestones reached". Two buttons: "Let's go" (page-colour fill) and "Share it" (1.5px white border).

**Titles and bodies come from `Milestone.swift` verbatim.** Do not invent thresholds. **No confetti or fireworks** — the 70-particle system in `CelebrationOverlay` is intentionally dropped; the moment is carried by the full-bleed panel. Keep the haptic.

### 11. Widgets (`extras.html` ← `DaysTilDisneyWidget.swift`)
All four `supportedFamilies`, radius 34, no watermark (the "Wish" mark is gone):
- **systemSmall** — two variants: countdown (park fill, label 10/700/+1.4, "45" at 62/800/−4, "days to go" 13/600) and packing (light fill, "12/38" at 52/800/−3, 8px progress bar).
- **systemMedium** — park fill, trip name label, "45 days" baseline-aligned (80/800/−5 + 18/600), and a right-aligned Karla 13 stack: date / nights / packed.
- **accessoryCircular** — 96px circle, 14% white, "45" 30/800 + "DAYS" 10/700.
- **accessoryRectangular** — "45" 34/800 beside trip name 13/700 and Karla 12 meta.

### 12. Share cards (`extras.html` ← `ShareCountdownCard.swift`)
4:5 at 1080×1350 (360×450pt). Park fill, radius 30, 24px padding. Countdown state: label, "45" numeral, "days to go" in gold 20/700, then a hairline rule (30% white) above trip name 17/600 and Karla 12 dates. Arrival state: "Today is / the day" at 46/800/−2 in place of the numeral. Footer: "COUNTDOWN TO MAGIC" 10/700/+1.4 at 72% white. No vignette, no watermark, no gold border gradient.

## Website (`website_kit/`)

Same stack as today's site (static HTML + CSS + vanilla JS), so this is a direct adaptation of `website/index.html`. Structure and copy are unchanged: nav · hero + phone · proof strip · 10 feature cards · daily content · 6 destinations · privacy/trust · extras · final CTA · footer. Replace in `website/styles.css`:

| Remove | Replace with |
|---|---|
| `.star-field` (both pseudo-elements + `twinkle-a/b` keyframes) | nothing — flat `--bg` |
| `.page-bg` `linear-gradient(160deg …)` | nothing |
| `.glass-card` (7% white, gold border, `backdrop-filter: blur(12px)`, `--shadow-card`) | flat `--surface` / `--surface-raised`, radius 22–34, no border, no shadow |
| `.btn--primary` gold gradient + glow | ink fill, no shadow |
| Nunito 400–900 | Outfit + Karla |
| Emoji icons (🎢 ⏳ ✨ 🧳 🇺🇸 …) and the `✨` logo stand-in | removed — cards lead with their title; brand is plain type |
| `.gold-divider` | 1px `--hairline` where a rule is still needed |

Keep: the `.reveal` `IntersectionObserver` pattern, the nav `.is-scrolled` state, smooth anchor scrolling, and `prefers-reduced-motion` handling — all already correct in `website/app.js`.

Three park-coloured moments only: the hero phone, the "Live ride wait times" feature card, and the final CTA.

## Interactions & behaviour

- **Navigation:** launch → welcome → new trip → home. Home → trip detail → packing list. Home "Next up" tile → milestone. Home trip row → park dashboard (when that trip is ongoing). Header "•••" → settings.
- **Countdown flip:** when the day changes, the numeral gets a single spring scale bump to 1.08 and back — `response: 0.4, dampingFraction: 0.6` out, `0.3 / 0.7` back. This matches the existing `CountdownHeroView` behaviour; keep it, and keep the `reduceMotion` guard.
- **Final day:** switches to hours + minutes ("14h 32m" / "UNTIL MAGIC"), per the existing `finalDayDisplay`. Ongoing trips switch to "Day X of Y".
- **Progress:** packing bars animate width on change (spring `0.4 / 0.8`).
- **Press states:** 96% scale on tiles and buttons, no colour change. Selected = ink fill inverting to page colour (chips, segmented control, sort pills) — never a colour swap. Disabled = 45% opacity.
- **Transitions:** screens cross-fade. No bounce on entry, no parallax, no particles.
- **Park selection:** toggling parks never empties the set; the first selected park drives theming.
- **Theme:** Light / Dark / System, persisted (existing `UserPreferences.ThemeMode`).

## State

No new state is required beyond what the ViewModels already expose — `HomeViewModel` (primary/secondary/past trips, daily content, active milestone), `TripDetailViewModel`, `PackingListViewModel` (sections, counts), `ParkDashboardViewModel` (live data, sort order, selected park), `SettingsViewModel`, `AddEditTripViewModel` (form + validity). The redesign is presentational.

One addition: the **milestone strip** on the milestone screen needs `Milestone.all` plus the current `daysUntilStart` to compute how many thresholds have passed. No new model.

## Assets

**None.** No images, icons, illustrations or fonts are bundled.

- The only glyphs are typographic, set in the UI font: `+`, `‹`, `•••`, `↻`, `›`, `✓`.
- Park identity is a colour, not a mark.
- No logo exists in the source; do not create one.
- Remove: the `WishStarShape` hero mark (and its duplicate `WidgetWishStarShape`), all ~30 SF Symbols, and `DisneyPark.emoji` from the UI (the property can stay as data).

## Files in this bundle

| Path | What it is |
|---|---|
| `design_system/` | The design system: `styles.css`, `tokens/`, `components/` (14 typed primitives with `.d.ts` + `.prompt.md`), `guidelines/` specimen cards, `readme.md`, `SKILL.md` |
| `ios_kit/index.html` | Click-through iOS app — open this first; it is the interactive spec |
| `ios_kit/*.js` | One file per screen, plus `shared.js` primitives |
| `ios_kit/extras.html` | Widgets + share cards |
| `website_kit/index.html` | Marketing site recreation |
| `designs/Countdown to Magic - Toy Box.dc.html` | All 14 screens side by side — the fastest way to see the whole system |
| `designs/Current App - Recreation.dc.html` | The **current** build, recreated from the Swift source — the before picture |
| `designs/Countdown to Magic - Directions v2.dc.html` | The three candidate directions; 4b (Toy Box) was chosen |
| `screenshots/01-all-screens-light-and-dark.png` | Every screen of the new system, light then dark |
| `screenshots/02-website.png` | The marketing page, full length |
| `screenshots/03-before-current-build.png` | The current build for comparison |

Start with `designs/Countdown to Magic - Toy Box.dc.html` for the overview, then `ios_kit/index.html` to feel the flow, then `design_system/readme.md` for the rules.

## Open questions for the team

1. **Fonts** — is licensing SF Pro Rounded's web equivalent (or shipping Outfit on web only) acceptable, or should both platforms move to one licensed family?
2. **Logo** — is a wordmark/mark planned? Several `TODO(design)` comments in `website/index.html` are waiting on one.
3. **Milestone celebration** — confirm dropping the particle system is intended. The design replaces it with a full-bleed panel + haptic.
4. **Android** — should the Compose implementation follow this exactly, or adapt to Material 3 conventions?
5. **`privacy.html`** — not recreated; needs the same treatment before launch.
