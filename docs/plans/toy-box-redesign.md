# Implementation Plan: "Toy Box" Visual Redesign — Countdown to Magic (iOS + Website)

**Branch:** `toy-box-redesign` (checked out)
**iOS project root:** `/Users/jamesoxenford/Developer/DaysTilDisney/ios/Days-Til-Disney/`
**Website root:** `/Users/jamesoxenford/Developer/DaysTilDisney/website/`
**Design spec (source of truth):** `docs/design/toy-box-redesign/` — `README.md` (master), `design_system/tokens/*.css`, `design_system/components/`, `ios_kit/`, `website_kit/`, `screenshots/`.
**Status:** Draft for plan-approval gate (Head of Agency + `staff-architect`). **Do NOT begin implementation until approved.**

---

## Objective

Replace the current "gradient + starfield + glass" visual system with the flat, chunky **Toy Box** direction: one park-coloured panel per screen, oversized geometric numerals, neutral surface steps, no shadows/blur/translucency, near icon-free. Apply across the full iOS surface (9 screens + 4 widget families + 2 share cards) and the marketing website. **Presentational only** — no new ViewModels, no data-model changes (one exception: the milestone screen reads `Milestone.all` + `daysUntilStart`, both already available).

This build is **also the App Store 5.2.1 resubmission**. It must preserve every just-merged rebrand fix (see Non-Negotiables) and must not reintroduce Disney trade dress. The redesign is already 5.2.1-favourable — it *removes* the Wish-star hero mark, the castle-adjacent gradients, and `DisneyPark.emoji` from the UI.

Android is **out of scope** this pass. **iPad IS in scope** — the Head of Agency approved a full iPad Toy Box adaptation (added scope; needs its own design pass, see below).

**Resubmission coupling (DECIDED — hard ship-together):** the App Store 5.2.1 resubmission is blocked on the **entire** redesign (iPhone + iPad + widgets + share cards + website) landing through review + QA. There is **no** sanctioned "removals-only compliance floor" fallback — the merged rebrand already clears 5.2.1 on `main`, but we are deliberately holding the resubmission for the full Toy Box build.

### iPad Design Dependency (gates Phase 4i) — DELIVERED
`mobile-ui-designer` produced the iPad adaptation: **`docs/design/toy-box-redesign/ipad-adaptation.md`**. Spine: a **size-class hybrid** — compact width (Slide Over / narrow split) renders the iPhone views unchanged; regular width uses either a max-width (~680pt) single column (Add Trip, Settings, Welcome, Packing, Milestone) or a two-column canvas (Home, Trip Detail, Park Dashboard). The old persistent left-hero/right-nav `iPadHomeLayout` shell is **deleted** (it puts two park panels on screen). Columns key off the `GeometryReader` container width (never a fraction of full screen), lead column capped at 420pt, one park panel per nav state. Numeral = share of panel height (~45% cap): 118/96 hold; milestone grows to 220–240. Ran in parallel with foundation; gates only **Phase 4i**.

---

## Non-Negotiables (verify at every checkpoint)

**5.2.1 / rebrand preservation (must stay true after the redesign):**
- App display name remains **"Countdown to Magic"** (home-screen label + widget gallery). Not touched by this plan; confirm no regression.
- **No Disney castle / trade dress** anywhere. The redesign removes the remaining decorative marks (Wish star via `HeroMarkView`, park `emoji`), so this pass *improves* compliance. Confirm nothing new reintroduces it.
- **Settings disclaimer verbatim**, `Features/Settings/SettingsView.swift:108`, `accessibilityIdentifier("about.disclaimer")`:
  `"Countdown to Magic is an unofficial app. Not affiliated with, endorsed by, or sponsored by The Walt Disney Company."`
  `RebrandQATests.checkDisclaimer` asserts this **exact** string (`:188`) — it must remain queryable and unchanged.
- **App icon stays** the current Wish-star launcher asset (asset catalog, unrelated to `HeroMarkView`). The redesign removes the Wish mark from *in-app hero surfaces only*, never the launcher.
- **No Disney character IP** in the UI.

**Presentational-only guardrail:**
- No changes to ViewModels, repositories, engines, or models except: **add** `ParkColorPalette.panelColor(for:)` (Phase 1) and **read** the existing `Milestone.all` in the new milestone screen (Phase 4.10). `DisneyPark.emoji` stays as a data property — only its UI *rendering* is removed.

**Tests must stay green (hard constraint, enumerated per screen):**
- `Days-Til-DisneyTests` (unit) — largely model/VM tests; redesign should not touch them. Any red = investigate before proceeding.
- `Days-Til-DisneyUITests/RebrandQATests.swift` drives the real UI and queries these accessibility handles — **all must survive the rewrite**:
  - Welcome: button label **"Create your first trip"**
  - Add-Trip: textField **"Trip name"**; save button **"Create Trip"**
  - Home: staticText **"Countdown to Magic"** (header wordmark), queryable at Dynamic Type **AX5 (XXXL)** without clipping; hero card tappable near normalized `(0.5, 0.34)`
  - Trip Detail: button **"Share countdown"**; a nav back button at `navigationBars.buttons[0]`
  - Home toolbar: button **"Settings"**
  - Settings: disclaimer exact string + `about.disclaimer` identifier
  - The QA file's header comment ("the Wish shooting-star mark renders") becomes stale — update the comment when the mark is removed (screenshots only, no assertion breaks).

**Label reconciliation (resolves a redesign-vs-test conflict — do this, don't skip):** several redesigned controls change their *visible* text while the UITests query the *old* string. The rule: **the accessibility label/identifier the test queries is preserved even when visible text changes.** Concretely —
- Home "•••" glyph `DTDIconButton` → `.accessibilityLabel("Settings")` (visible glyph is `•••`, test queries `buttons["Settings"]`).
- AddTrip header "Save" → keep `.accessibilityLabel("Create Trip")` (or rename the test in the same change — pick one, don't leave it implicit).
- TripDetail "Share" text button → keep `.accessibilityLabel("Share countdown")`.
- AddTrip name field stays a `TextField` with accessibility label **"Trip name"**; Welcome primary button keeps visible+accessible label **"Create your first trip"**.
- **Enforcement:** make `DTDIconButton` (Phase 2) take a **required** `accessibilityLabel` param so no glyph-only button can ship unlabeled.

---

## The one correctness item (get this right first)

Park-panel colour is **theme-resolved inside the model**, never branched at call sites. `ParkColorPalette` currently has **no** `deep`/dark variant and no colorScheme awareness; the `-deep` tone is that struct's existing `backgroundGradientMid1` stop (verified: MK `primary #1A3A6B` / `backgroundGradientMid1 #0D2545`, matching the token file's `--park-magic-kingdom` / `-deep`).

Add exactly one resolver:

```swift
// Core/Models/ParkColorPalette.swift
extension ParkColorPalette {
    /// The single park-coloured panel fill. Resolves to `primary` on light and the
    /// `-deep` tone (`backgroundGradientMid1`) on dark. No call site branches on colorScheme.
    func panelColor(for scheme: ColorScheme) -> Color {
        scheme == .dark ? backgroundGradientMid1 : primary
    }
}
```

Every panel fill is `park.colorPalette.panelColor(for: colorScheme)` reading `@Environment(\.colorScheme)`. **A `if colorScheme == .dark` at any panel call site is a bug.** (Handoff calls this "the single most repeated bug during design.")

Two colorScheme gotchas baked into the phases below:
- **`ImageRenderer` (share cards) does not inherit `@Environment(\.colorScheme)`.** Pass the scheme explicitly. `ShareCountdownCard` already takes explicit values — keep that shape; add an explicit `scheme` (or resolved `panelColor`) parameter.
- **Widgets** get colorScheme from their render environment normally — fine.

---

## Open-question defaults (decisions baked in; flag at the gate if any is wrong)

1. **Fonts.** iOS keeps **SF Pro Rounded** (the design's Outfit is a web substitute). Map Outfit weights → system weights: **800 → `.black`, 700 → `.bold`, 600 → `.semibold`, 500 → `.medium`, 400 → `.regular`.** `DTDFont` already uses `.system(design: .rounded)`, so this is a token extension, not a font-file addition. Web keeps **Outfit + Karla** (Google Fonts). Prose on iOS (Karla role) → `.system(design: .default)`.
2. **Logo.** Wordmark-only, plain type ("Countdown to Magic", SF Rounded semibold ~19px). **No mark invented.**
3. **Milestone celebration.** Drop the `CelebrationOverlay` 70-particle system. Keep the **haptic** and the full-bleed park panel. (See Phase 4.10.)
4. **`privacy.html`** is **in website scope** (Phase 7) — it needs the same de-glassing treatment though it is not in `website_kit/`.
5. **Milestone copy → sentence case (DECIDED at gate).** Update the `Milestone.swift` title strings from Title Case ("One Month to Go!") to sentence case ("One month to go!") so source and mockups agree and the whole app honors the design system's sentence-case rule. This is a **sanctioned deliberate copy edit** — an explicit, approved exception to presentational-only (data strings change, but it's a copy correction, not a behaviour change). Update any unit test that asserts a milestone title string in the same change. `MilestoneNotificationManager` uses the same titles — confirm the notification copy reads correctly sentence-cased too (in scope for this string edit).
6. **iPad → FULL Toy Box adaptation (DECIDED at gate — added scope).** Toy Box specs iPhone 390×844 only, so a proper iPad layout must be **designed first** (`mobile-ui-designer`) and then built. This is a real scope addition beyond the original iPhone-only handoff. See the **iPad Design Dependency** note below and **Phase 4i**. iPad is now a hard part of this ship (per "hard ship-together").

---

## Phasing overview

| Phase | Scope | Owner | Gate/Checkpoint |
|---|---|---|---|
| 0 | Branch hygiene, baseline green | dev | build + tests baseline |
| 1 | **Foundation** — token layer, type scale + tracking helper, `panelColor(for:)`, removal of gradient/starfield/glass/shadow infra | dev | CP-1 |
| 2 | Core components (Button, IconButton, Chip, SectionLabel, ProgressBar, Checkbox, Toggle, SegmentedControl) | dev | CP-2 |
| 3 | Countdown components (ParkPanel, CountdownNumeral, StatTile, TripRow, WaitPill, MilestoneStrip) | dev | CP-3 |
| 4 | Screens 1–11 (screen-by-screen restyle; milestone screen is new UI + 1 new route) | dev | CP-4.x per screen |
| 4i | **iPad Toy Box layout** — full adaptation (added scope; gated on the iPad design pass) | dev + `mobile-ui-designer` | CP-4i |
| 5 | Widgets (systemSmall ×2 / systemMedium / accessoryCircular / accessoryRectangular) | dev | CP-5 |
| 6 | Share cards (countdown + arrival states) | dev | CP-6 |
| 7 | Website (`website/` incl. `privacy.html`) | `web-marketing-dev` | CP-7 |
| 8 | Full QA pass — per-screen visual (light + dark), Dynamic Type, tests | QA (`ios-ui-testing`) | Release gate |

Foundation is strictly first (everything depends on tokens + `panelColor`). Components before screens. Widgets/share cards after screens (they reuse the resolver). Website is independent and can run in parallel from Phase 1 onward.

---

## Phase 0 — Baseline

- Confirm `toy-box-redesign` is checked out. **Reconcile the working tree NOW (architect gate — do not defer to Phase 7):** the branch has uncommitted `website/{index.html,privacy.html,styles.css}` marketing edits from prior work, plus the newly vendored `docs/design/toy-box-redesign/` design bundle. Decide explicitly at CP-0 — **commit the design bundle** to the branch, and **commit or stash** the loose website edits — so Phase 7's CSS rewrite cannot silently clobber uncommitted work. Record what was done here.
- Run **`xcodebuild build`** + **`xcodebuild test`** on `Days-Til-Disney` scheme. Record the baseline: which tests pass today. This is the green bar the redesign must hold.
- **`RebrandQATests.swift` caveat (must verify at CP-0):** this 237-line UITest is the guardrail the whole plan cites, but it was created ad-hoc during the rebrand QA, was **never committed** (untracked until this branch), and has **no verified green run** (the QA agent that wrote it looped before finishing). It IS auto-compiled (the UITests dir is a `PBXFileSystemSynchronizedRootGroup`). **CP-0 must confirm it compiles and passes.** If it is red or non-compiling, fixing/repairing it is the *first* task — otherwise the plan's "preserve these handles" guarantee is hollow. Do not treat it as the green bar until CP-0 proves it green.

**CP-0:** Baseline build + test result recorded, working tree reconciled (design bundle + website edits committed/stashed per above), and `RebrandQATests` confirmed compiling + passing (or repaired).

---

## Phase 1 — Foundation (theme/token layer)

Everything else builds on this. Land it and stabilize before any component work.

### 1a. Semantic colour roles

Add the Toy Box role tokens as a theme-aware colour source. Model as static `Color` accessors that resolve against `@Environment(\.colorScheme)` (SwiftUI `Color(uiColor:)` with a trait-based resolver, or a small `DTDColor` enum returning `Color` given a scheme). Values verbatim from `design_system/tokens/colors.css`:

- Surfaces: `bg`, `surface`, `surface-raised`, `surface-control`, `hairline` (light `#F3F3F1 / #E7E7E3 / #FFFFFF / #E4E4E0 / #D2D2CD`; dark `#15151A / #202028 / #26262E / #26262E / #2E2E38`).
- Text: `text-primary`, `text-muted`, `text-faint`, `text-done` (light `#1B1B1F / #5F5F66 / #63636A / #6E6E75`; dark `#F1F1EF / #9A99A2 / #93929B / #93929B`).
- Interactive: `accent-interactive` (light `#1A3A6B` / dark gold `#E8C84A`), `on-accent` (light `#FFFFFF` / dark `#3E3208`), `knob` (light `#F3F3F1` / dark `#15151A`).
- Gold: `gold #E8C84A`, `gold-deep #C9A84C`, `gold-ink #3E3208`, `gold-label` (light `#7A6420` / dark `#E8C84A`).
- Wait-time **text** roles: `wait-short` (`#2E7D32 / #4CAF50`), `wait-mid` (`#7A6420 / #E8C84A`), `wait-long` (`#C0392B / #FF6B6B`).
- Status **fills** (surface-agnostic dots/badges): operating `#4CAF50`, closed `#F44336`, refurb `#FF9800`, long-wait `#FF6B6B`.
- On-park transparencies: white `.18` (chips/badges), `.78–.85` (secondary text on panel), outline `1.5px rgba(255,255,255,.35)`.

Reuse the existing `Color(hex:)` in `Core/Extensions/Color+Hex.swift` (already a widget-target member). Keep `Color.disneyGold`/`Color.magicSparkle` as-is (internal names, Bucket A from the rebrand plan).

**Files:** new `DesignSystem/DTDColor.swift` (or extend `Color+Hex.swift`).

### 1b. `panelColor(for:)`

Add the resolver from **The one correctness item** above to `Core/Models/ParkColorPalette.swift`. One method, no call-site branching.

**Files:** `Core/Models/ParkColorPalette.swift`.

### 1c. Type scale + tracking/leading helper

`Font` carries no tracking, and SwiftUI `.lineSpacing()` is *additive points*, not a CSS multiplier — sub-1.0 leading (0.84 hero, 0.82 milestone) cannot be expressed as `.lineSpacing`. So **a `Font` token alone is insufficient.** Ship a text-style helper that bundles font + weight + tracking + leading per role, so no numeral call site hand-rolls `.tracking()` and drifts.

Add to `DesignSystem/Typography.swift` (extend `DTDFont`) plus a companion `Text`/`ViewModifier` style set. Roles + values verbatim from `design_system/tokens/typography.css` and README §Typography:

| Role | Size | Weight (system) | Tracking | Leading note |
|---|---|---|---|---|
| numeral hero | 118 | `.black` | −7 | tight; `minimumScaleFactor` + `allowsTightening` |
| numeral screen | 96 | `.black` | −6 | tight |
| numeral milestone | 172 | `.black` | −12 | tight |
| numeral stat | 40 | `.black` | −2 | — |
| numeral inline (wait) | 26 | `.black` | −1 | — |
| display | 38 | `.black` | −1.4 | leading 1.08 |
| title | 24 | `.semibold` | −0.4 | 1.2 |
| heading | 23 | `.bold` | −0.4 | 1.25 |
| body-strong | 17 | `.semibold`/`.bold` | −0.2 | — |
| body | 16 | `.medium`/`.semibold` | — | — |
| prose (Karla → `.default`) | 15 | `.regular` | — | 1.55 |
| caption (`.default`) | 13 | `.regular`–`.semibold` | — | — |
| label | 12 | `.bold` | +1.4 upper | — |
| label-loose | 12 | `.bold` | +2.4 upper | — |
| label-sm | 11 | `.bold` | +0.8–1.6 upper | — |

Tracking → SwiftUI `.tracking(px)` (px≈pt here). Leading <1.0 → apply via `.lineSpacing(negative)` computed from `(leading−1)·size`, or set line height on the numeral by clamping the frame; document one approach in the helper and reuse it. Denominators ("/38") = parent numeral at half size in `text-faint`.

**Dynamic Type policy (handoff omits this; project requires it):**
- **Numerals** are fixed-size by design → use fixed `.system(size:)` with `.minimumScaleFactor(0.3)` + `.allowsTightening(true)` (mirrors existing `countdownStyle()`), so they shrink rather than clip at large text.
- **Body / prose / caption / label** must scale → use `.system(<textStyle>, design:, weight:)` (relative) or `.custom(size:relativeTo:)`, not raw fixed `.system(size:)`. The existing `DTDFont.body/caption/label` are already text-style-relative — keep that pattern for prose roles.
- The Home header wordmark must remain queryable and non-clipping at **AX5** (`RebrandQATests.test_homeHeaderAX5`). No `.fixedSize()` that clips.

**Files:** `DesignSystem/Typography.swift`, optional new `DesignSystem/TextStyles.swift`.

### 1d. Radii + spacing constants

Add from `radii.css` / `spacing.css`: radii `check 9, control 14, chip 16, tile-sm 22, tile 26, card 30, hero/panel 34, pill 999`; spacing `4,6,8,10,12,14,16,18,20,22,24,26,30,36`, gutter 20, tile gap 12, tap-min 44. Use `RoundedRectangle(cornerRadius:, style: .continuous)` everywhere. Nothing square; nothing sharper than 9.

**Files:** new `DesignSystem/DTDLayout.swift` (radii + spacing enums).

### 1e. Remove the old visual infra

Flat means **no shadow, no blur, no translucency, no gradient, no starfield, no glow**. Removal inventory (verified paths/lines):

- **Delete** `DesignSystem/Components/GradientBackgroundView.swift` (contains both `GradientBackgroundView` and `StarFieldView`, line ~28). Remove its usages: `HomeView.swift:22`, `iPadHomeLayout.swift:66,184`, `ParkDashboardView.swift:18`, `PackingListView.swift:15`, `WelcomeView.swift:29`, `TripDetailView.swift:19` (+ previews). Replace each screen background with flat `DTDColor.bg`.
- **Delete** `DesignSystem/Components/CastleSilhouetteView.swift` (misnamed — it actually defines `HeroMarkView`, `WishStarShape`, `enum WishStar`; **no castle type exists**). Remove `HeroMarkView` from all 9 call sites: `CountdownHeroView.swift:69`, `HomeView.swift:251`, `iPadHomeLayout.swift:104,213`, `SplashView.swift:30`, `ShareCountdownCard.swift:43`, `TripDetailView.swift:101,134`, `WelcomeView.swift:36`. (App-icon asset untouched.)
- **Remove** `.ultraThinMaterial` at: `CelebrationOverlay.swift:159` (whole overlay is dropped — 4.10), `CountdownHeroView.swift:37`, `DailyContentCardView.swift:76`, `TripCardView.swift:76`, `ParkDashboardView.swift:380,501`, `LiveParkCard.swift:99`. Replace with flat `surface`/`surface-raised`.
- **Remove** the two-layer shadow + accent bloom on `CountdownHeroView.swift:117–119`. No shadows anywhere in-app.
- **Time-of-day engine becomes dead code.** With gradient/starfield/overlays gone, the panel only needs `trip.primaryPark.colorPalette.panelColor(for:)`. **DECIDED (architect gate — option b, keeps the presentational-only guardrail literally true):** keep `ParkThemeProvider` as a **thin park-identity holder** (park only — no overlays, no gradients, no time-of-day), and keep its `setActivePark(_:)` API. This means **`HomeViewModel` is NOT touched** — its `themeProvider` injection (`:32,:41`), the `setActivePark` call (`:97`), and the preview construction (`:178`) all stay as-is, so there is **no `HomeViewModel` init-signature change**.
  - **Delete only the visual surface** of the theme engine: `Engine/Theme/TimeOfDayProvider.swift`, the `TimeOfDay` overlay logic + `richGradientColors`/`gradient`/overlay hexes in `Engine/Theme/ParkThemeProvider.swift` (reduce it to the park-identity holder), and the `TimeOfDayOverlay` statics (`dawnOverlay/dayOverlay/duskOverlay/nightOverlay`) in `ParkColorPalette.swift`.
  - Views that read the provider for `accentColor`/`currentTheme` migrate to reading the park directly (`trip.primaryPark`) + `panelColor(for:)`. The provider stays injected but its *colour/gradient* surface is gone.
  - **This is settled at plan time — not a CP-1 decision.** Do NOT delete `ParkThemeProvider` wholesale (that would force a `HomeViewModel` init change and violate the guardrail).

**CP-1 (foundation gate):** App builds with the new token/type/layout layer and `panelColor(for:)`; all gradient/starfield/glass/shadow/hero-mark infra deleted or stubbed; screens temporarily render on flat `bg` (unstyled but not crashing); **existing tests still green**. Do not proceed to components until green.

---

## Phase 2 — Core components (native, from `design_system/components/core/`)

Build as reusable SwiftUI views under `DesignSystem/Components/`. `.d.ts`/`.prompt.md` document props/states; **do not port `.jsx`.** All press states = 96% scale, no colour change; disabled = 45% opacity; selected = ink fill inverting to page colour (never a colour swap).

| Component | Props (from `.d.ts`) | States | Notes |
|---|---|---|---|
| `DTDButton` | `variant: primary\|secondary\|onPark\|outlineOnPark`, `full`, `disabled` | press 96%, disabled 45% | primary = ink fill; secondary = `surface`; onPark = white/tint on panel; outline = 1.5px white border on panel. radius 20–22. |
| `DTDIconButton` | glyph (`+ ‹ ••• ↻ › ✓`), **required `accessibilityLabel`**, `variant` | press | typographic glyph in SF Rounded, **not** SF Symbol. 36px, radius 14. `+` on ink, `•••` on `surface-control`. The required label param is what keeps `buttons["Settings"]` etc. queryable (see Label reconciliation). |
| `DTDChip` | label, `selected` | selected = ink fill → page colour | radius 999. |
| `SectionLabel` | text | — | 12/700 uppercase, tracking +1.4, `text-muted`. Extracted (was inline). |
| `DTDProgressBar` | value 0–1, tint | animates width, spring `0.4/0.8` | 8–10px, `accent-interactive` on `hairline`; gold on panel. |
| `DTDCheckbox` | `checked`, size (20/24) | checked = `accent-interactive` fill + `on-accent` ✓ | radius 9; unchecked = 2px `hairline` border. |
| `DTDToggle` | `isOn` | knob spring | 50×30 track, 24px knob, 3px inset; track `accent-interactive`, knob `knob`. |
| `SegmentedControl` | `options`, `value` | active = ink fill | radius 14; Light/Dark/System. Extracted (was inline). |

**CP-2:** Component gallery (SwiftUI previews) renders all 8 in light + dark, all states. Match `design_system/guidelines/*` specimen cards.

---

## Phase 3 — Countdown components (from `design_system/components/countdown/`)

| Component | Props | Notes |
|---|---|---|
| `ParkPanel` | `park: DisneyPark`, `label`, `badge?`, `compact?`, content | **The** single park-coloured surface. Fill = `park.colorPalette.panelColor(for: colorScheme)`. radius 34, padding 24/26. `badge` = white-`.18` pill ("PRIMARY"/"IN PARK"). **Never gradient, never raw primary.** One per screen. |
| `CountdownNumeral` | `value`, `unit?`, `size: hero\|screen\|milestone`, `onPark?` | Numeral role from Phase 1c. `unit` ("days"/"of 7 days") sits on baseline. Never centred, never outlined, never per-digit animated. Keep the day-flip spring bump (see Motion). |
| `StatTile` | label, numeral, trailing (progress bar or caption) | radius 26, padding 18/20; pairs only. |
| `TripRow` | park swatch (44px, radius 16), name 17/600, meta, `›` | past trips at 60% opacity. |
| `WaitPill` | `minutes: Int?` (nil→"Walk-on"), `status` | 19/700 in `wait-*` colour on 6% neutral wash. `status` mirrors `AttractionStatus`. |
| `MilestoneStrip` | `daysOut: Int`, `onPark?` | **New UI.** 8 segments (100/50/30/14/7/3/1/0 from `Milestone.all`); passed = gold, remaining = 28% white; caption "N of 8 milestones reached". Renders existing data — no new thresholds. |

**CP-3:** All six render in previews (light + dark, on-park and neutral variants); `panelColor(for:)` verified correct on both schemes for ≥3 parks.

---

## Phase 4 — Screens (restyle in place; presentational)

For every screen: replace the deleted background with flat `bg`, restyle to the spec, preserve all UITest accessibility handles (see Non-Negotiables), and QA in **light and dark**. Spec refs point to `docs/design/toy-box-redesign/README.md §Screens` and the matching `ios_kit/*.js`.

Each screen keeps its existing ViewModel and state exactly. `.emoji` UI rendering is removed only on the screens listed here (property stays as data; `MilestoneNotificationManager`/`DefaultMilestoneManager` usages are **out of scope** — do not touch).

### 4.1 Launch — `Features/Splash/SplashView.swift` (`splash.js`)
132×132 park panel (radius 44) with "45" bottom-aligned; "Countdown / to Magic" 44/800; "Getting your trips…" Karla 16 muted; 8px progress at 62%. Remove `HeroMarkView` (`:30`). Keep ~1.6–2.2s auto-advance. **CP-4.1.**

### 4.2 Welcome — `Features/Onboarding/WelcomeView.swift` (`welcome.js`)
3×2 grid of 1:1 tiles (radius 22, 10px gap; tiles 1/3/5 filled navy/red/gold, 2/4/6 `surface`) — replaces the old hero mark + constellation. Headline "The best part / starts early." 38/800. Body Karla 17. Stacked full-width buttons (primary ink, secondary `surface`). Remove `HeroMarkView` (`:36`) + starfield (`:29`). **Preserve button label "Create your first trip".** **CP-4.2.**

### 4.3 Home — `Features/Home/HomeView.swift` + `Components/{CountdownHeroView,TripCardView,DailyContentCardView}` (`home.js`)
Header: wordmark 19/700 left (keep staticText **"Countdown to Magic"**, AX5-safe); two 36px icon buttons right ("+" ink, "•••" `surface-control` → Settings). One `ParkPanel` hero: park label + "PRIMARY" pill, 118/800 numeral + "days" on baseline, trip name 24/600, dates Karla 13. Two `StatTile`s (Packed = progress; Next up = caption → milestone). `DailyContentCardView` on `surface-raised`: gold dot + "TODAY'S FACT" (`gold-label`), heading 23/700, body Karla 15. `TripRow`s (past at 60%).
- Rewrite `CountdownHeroView`: remove `.ultraThinMaterial` (`:37`), the double shadow/bloom (`:117–119`), and `HeroMarkView` (`:69`); keep the day-flip spring bump, `finalDayDisplay` (h/m), `ongoingDisplay` (Day X of Y). **Keep the hero tappable near `(0.5,0.34)`** and the toolbar **"Settings"** button.
- `iPadHomeLayout.swift`: mirror all removals (`:54,66,104,184,213`).
**CP-4.3.**

### 4.4 Empty state — `HomeView.EmptyTripsView` (`empty.js`)
`surface` panel (radius 34): "00" 96/800 in `text-faint`, "Nothing to count down to — yet." 26/700, Karla body, ink "Add a trip" button. Two `surface-raised` stat tiles (PARKS 12 / TIPS 1/day). **CP-4.4.**

### 4.5 New trip — `Features/AddEditTrip/AddEditTripView.swift` + `Components/ParkSelectorView.swift` (`addTrip.js`)
Header: "Cancel"/"New trip"/"Save" (Save 45% until `AddEditTripViewModel.form.isValid`). Name + two date cards on `surface-raised`, value 22/700 with `accent-interactive` caret. **Resort panel** = the park `ParkPanel`: resort name + "SELECTED" pill, park rows (selected = white-`.16` fill + white check; unselected = 1.5px white border; first selected tagged "THEME"). Other resorts as `surface` pills. "Primary countdown" toggle row.
- **Remove `.emoji` rendering** at `ParkSelectorView.swift:166` (park identity → colour swatch).
- **Remove the forced `.preferredColorScheme(.dark)`** on this screen (blocks light-mode QA).
- Preserve textField **"Trip name"** and save button **"Create Trip"**. At-least-one-park-selected invariant unchanged. **CP-4.5.**

### 4.6 Trip detail — `Features/TripDetail/TripDetailView.swift` + `LiveParkCard.swift` (`tripDetail.js`)
Back + "Share"/"Edit" text buttons (`surface-control`, radius 14). `ParkPanel` with 96/800 numeral, trip name 22/600, park chips. Three metric tiles (START/END/NIGHTS, radius 22, 20/700). Packing row on `surface-raised` with inline progress + "12 of 38". Notes card (gold dot when notes exist). Tips list with day-offset badges on ink pills. Remove `HeroMarkView` (`:101,134`), `.ultraThinMaterial` (`LiveParkCard:99`), starfield (`:19`), and the `CelebrationOverlay` trigger (`:68`, see 4.10). **Preserve "Share countdown" button** and nav back. **CP-4.6.**

### 4.7 Packing list — `Features/PackingList/PackingListView.swift` (`packingList.js`)
Summary `ParkPanel` (radius 30): "12/38" 64/800 (denominator 28 at 70% white), "26 to go" Karla 14, 10px gold progress on white-`.22`. Category cards on `surface-raised` (radius 26): `SectionLabel` + "3/8", rows with `DTDCheckbox` (24px, radius 9); checked = fill + `on-accent` ✓ + `text-done` strikethrough. Item names from `DefaultPackingItems` verbatim. "+ Add your own item" footer. Remove starfield (`:15`). **CP-4.7.**

### 4.8 Park dashboard — `Features/ParkDashboard/ParkDashboardView.swift` (`parkDashboard.js`)
Park selector `DTDChip`s (selected = ink). Summary panel in the park's **deep** tone — this is the **one sanctioned constant-tone site** (architect gate): the spec always wants the deep tone here regardless of the app's light/dark scheme, so call `park.colorPalette.panelColor(for: .dark)` **as a deliberate constant, not a `colorScheme` branch**. Do NOT add a separate `deepColor` accessor — passing `.dark` to the existing resolver is the correct, minimal call. (This is the sole exception to "never pass a fixed scheme"; every *other* panel reads `@Environment(\.colorScheme)`.) Three stats 34/800: OPEN/AVG MIN/SHORTEST. Sort pills (active = gold fill, gold-ink). Attraction rows on `surface` (radius 22): name 16/600, optional meta Karla 12, `WaitPill` 19/700. Non-operating rows: name in `text-faint` + neutral "REFURB"/"CLOSED" chip.
- **Only render `LiveAttraction` fields that exist:** `name`, `status`, `standbyWaitMinutes` (nil→"Walk-on"), `lightningLaneReturnWindow.displayString`, `paidLightningLanePrice.displayPrice`, `lastUpdated`. **No land/area field — do not add one.**
- Remove `.ultraThinMaterial` (`:380,501`) + starfield (`:18`). **CP-4.8.**

### 4.9 Settings — `Features/Settings/SettingsView.swift` (`settings.js`)
Appearance card with `SegmentedControl` (Light/Dark/System, active ink). Two toggle rows (iCloud sync, milestone notifications), title 16/600 + Karla 13 subtitle. About card, hairline-divided rows (Version / Privacy policy / Support). **Legal line verbatim, `about.disclaimer` identifier preserved** (Non-Negotiables). **Remove the forced `.preferredColorScheme(.dark)`.** Wire theme selection to existing `UserPreferences.ThemeMode`. **CP-4.9.**

### 4.10 Milestone — NEW SCREEN: `Features/Milestone/MilestoneView.swift` (`milestone.js`)
**This is genuinely new UI + one new route — not a restyle.** Today milestones exist *only* as the triggered `CelebrationOverlay`; there is no `MilestoneView`.
- Build one full-bleed `ParkPanel` (no status spacer): "MILESTONE · MAGIC KINGDOM" 12/700/+2.4; numeral 172/800; **title in gold 40/800 (verbatim from `Milestone.title`)**; body Karla 17 (`Milestone.subtitle`); `MilestoneStrip(daysOut:)`; two buttons "Let's go" (page-colour fill) and "Share it" (white border).
- Present it from **both**: the Home "Next up" `StatTile` tap (on-demand), and the existing milestone trigger (replaces the `CelebrationOverlay` presentation at `HomeView.swift:63`, `iPadHomeLayout.swift:54`, `TripDetailView.swift:68`).
- Add **one route** to `Navigation/AppNavigationRouter.swift`. **Route signature (architect gate — defined at plan time):** `case milestone(tripID: UUID)`, matching the existing cases' `tripID`/`park` payload convention. `MilestoneView` resolves `daysUntilStart`, `primaryPark`, and the matching `Milestone` from the trip (via the existing `HomeViewModel`/`TripDetailViewModel` context) — the route carries only the `tripID`, no denormalized payload.
- **Delete** `DesignSystem/Animations/CelebrationOverlay.swift` and its three call sites. **Keep the haptic** (relocate the `MilestoneEvent` haptic into the presentation path — the `CelebrationType.isHeavyHaptic` hint still applies). No confetti/fireworks/particles.
- Milestone titles render **sentence case** (per gate decision — the `Milestone.swift` strings are edited to sentence case in Phase 1/foundation as a sanctioned copy correction; see Open-question default #5).
**CP-4.10.**

### 4i iPad — full Toy Box adaptation (`iPadHomeLayout.swift` + iPad layouts)
**Added scope, gated on the iPad design pass (`mobile-ui-designer`).** Beyond the infra removals already done in Phase 1e/4.3, build the iPad Toy Box layout to the design pass's spec: how the one-park-panel rule and tile stacks reflow on the large canvas (multi-column / max content width / split behaviour), across all size classes and orientations, light + dark. Reuse the Phase 2/3 components — do not fork them. Do not start until the iPad design is delivered and approved. **CP-4i.**

---

## Phase 5 — Widgets — `DaysTilDisneyWidget/DaysTilDisneyWidget.swift` (`extras.html`)

`supportedFamilies` today = **`.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular`** (no systemLarge — matches "4 families"). Restyle each, radius 34, flat park fill via `panelColor`, **no watermark** (remove `WidgetHeroMark` + `WidgetWishStarShape` at `:351,364`) and **no `.emoji`** (`:126,179,233,244,287`; `WidgetDataProvider.swift:78`).

- **systemSmall** — two variants: countdown (park fill, label 10/700, "45" 62/800, "days to go" 13/600) and packing (light fill, "12/38" 52/800, 8px progress).
- **systemMedium** — park fill, trip label, "45 days" baseline (80/800 + 18/600), right Karla 13 stack (date/nights/packed).
- **accessoryCircular** — 96px circle, 14% white, "45" 30/800 + "DAYS" 10/700.
- **accessoryRectangular** — "45" 34/800 + trip name 13/700 + Karla 12 meta.
- Replace `containerBackground` (currently park `gradientStops`) with the flat `panelColor`.

**Widget target membership (gating):** the widget is a `PBXFileSystemSynchronizedRootGroup`; shared files come in via `membershipExceptions` in `project.pbxproj` (verified list already includes `ParkColorPalette.swift`, `Color+Hex.swift`, `DisneyPark.swift`, `Trip.swift`). So `panelColor(for:)` is available to the widget **for free**. **But** the new **Phase-1 type/color/layout files (`Typography.swift`, `DTDColor.swift`, `DTDLayout.swift`) are NOT members** — the widget currently hand-rolls raw `.system(...)`. **Decision:** add the new foundation file(s) to the widget's `membershipExceptions` set so widgets use the same tokens (edit via Xcode target membership to keep pbxproj well-formed). Fallback if that's noisy: widget hand-rolls the same numeral sizes/weights locally (they're just `.system(size:weight:.black,design:.rounded)` + `.tracking`), duplicating values — acceptable given the existing SYNC-NOTE precedent, but prefer shared membership.

**CP-5:** All four families render in the widget gallery + on a home screen, light + dark, no watermark/emoji, existing placed widgets still resolve (`kind` unchanged).

---

## Phase 6 — Share cards — `Features/TripDetail/ShareCountdownCard.swift` (`extras.html`)

4:5 at 360×450pt (`ImageRenderer` export). Two states:
- **Countdown:** park fill (radius 30, 24px pad), label, "45" numeral, "days to go" gold 20/700, hairline rule (30% white), trip name 17/600, Karla 12 dates.
- **Arrival:** "Today is / the day" 46/800 in place of the numeral.
- Footer "COUNTDOWN TO MAGIC" 10/700 at 72% white.

Remove: `HeroMarkView` watermark (`:43`), the radial vignette, the gold accent-gradient border, the `wand.and.stars` footer symbol, and **`.emoji`** (`:183`). No vignette, no watermark, no gold border.

**colorScheme gotcha:** `ImageRenderer` does **not** inherit `@Environment(\.colorScheme)`. The current `init` already passes explicit values (incl. `gradientColors`, `accentColor`) — replace those with an explicit resolved **`panelColor`** (or an explicit `scheme` param) so the exported PNG is deterministic. Default arrival/countdown exports to the light (`primary`) panel unless a scheme is threaded through from the sharing screen.

**CP-6:** Both states render via `ImageRenderer` at 1080×1350; visually match `extras.html`; no trade dress.

---

## Phase 7 — Website — `website/` (owner: `web-marketing-dev`)

Same static stack (HTML + CSS + vanilla JS) — a **direct adaptation** of `website_kit/`. Structure + copy unchanged (nav · hero+phone · proof · 10 feature cards · daily content · 6 destinations · privacy/trust · extras · final CTA · footer). Edit `website/styles.css`:

| Remove | Replace with |
|---|---|
| `.star-field` (both pseudo-elements + `twinkle-a/b`) | nothing — flat `--bg` |
| `.page-bg` `linear-gradient(160deg …)` | nothing |
| `.glass-card` (blur, gold border, `--shadow-card`) | flat `--surface`/`--surface-raised`, radius 22–34, no border, no shadow |
| `.btn--primary` gold gradient + glow | ink fill, no shadow |
| Nunito 400–900 | Outfit + Karla (Google Fonts) |
| Emoji icons + `✨` logo stand-in | removed — cards lead with title; brand = plain type |
| `.gold-divider` | 1px `--hairline` where a rule is needed |

Keep the `.reveal` IntersectionObserver, nav `.is-scrolled`, smooth anchor scroll, and `prefers-reduced-motion` handling (already correct in `website/app.js`). Three park-coloured moments only: hero phone, "Live ride wait times" card, final CTA.

**`privacy.html` is in scope** (open-question default): apply the same de-glassing/token treatment though it is not in `website_kit/`. Reconcile with the **uncommitted `website/` edits** already on this branch before starting.

**CP-7:** `website/index.html` + `privacy.html` render flat, responsive, light/dark; Lighthouse/`prefers-reduced-motion` intact; no emoji/glass/gradient remnants.

---

## Cross-cutting requirements

- **Motion / Reduce Motion:** keep the countdown day-flip spring bump (`response 0.4, damping 0.6` out; `0.3/0.7` back) with the existing `reduceMotion` guard. Progress bars animate width (spring `0.4/0.8`). Screens cross-fade. No bounce/parallax/particles. Press = 96% scale only.
- **Accessibility:** every text colour clears WCAG AA 4.5:1 on its own surface (per `color-palettes.md`); wait-time colours set at 19px/700 to qualify as large text at 3:1 — **do not shrink without darkening.** Preserve all `accessibilityIdentifier`/`accessibilityLabel` handles the UITests query. Dynamic Type policy per Phase 1c.
- **Theme:** Light / Dark / System via existing `UserPreferences.ThemeMode`, applied in `DaysTilDisneyApp.swift:26`. Remove the two forced `.preferredColorScheme(.dark)` overrides (Settings, AddEditTrip).

---

## Test impact

- **Unit (`Days-Til-DisneyTests`):** model/VM/repository tests — the redesign is presentational, so these should stay green untouched. `MilestoneTests` covers `Milestone.all`/`matching` (unchanged). If any go red, a non-presentational change leaked — stop and fix.
- **UI (`RebrandQATests`):** no assertions change, but the rewrite must keep every queried handle (enumerated in Non-Negotiables). Update the file's stale header comment (Wish mark now removed). The AX5 header test must still find non-clipping "Countdown to Magic".
- **New coverage (optional, lazy):** the milestone-strip "N passed" computation is the only new non-trivial logic — a tiny unit test over `Milestone.all` + a `daysOut` input (e.g. `daysOut=30` → 3 of 8 reached) is worth one assertion. No new frameworks.
- No snapshot tests exist in the repo today; the primary visual gate is the `ios-ui-testing` per-screen screenshot pass, not snapshots.

---

## Verification / QA (Phase 8, release gate)

1. **Build:** `xcodebuild build` on `Days-Til-Disney` + widget extension, clean.
2. **Tests:** `xcodebuild test` — unit + `RebrandQATests` green (same bar as CP-0).
3. **Per-screen visual pass in LIGHT and DARK** (the primary QA) via the `ios-ui-testing` skill / simulator: all 11 screens, 4 widget families, 2 share-card states, **plus the iPad layout (Phase 4i) on an iPad simulator across orientations**. Verify: exactly one park panel per screen; no gradient/blur/shadow/starfield/glow; no Wish mark; no emoji; `panelColor` correct on both schemes.
4. **Dynamic Type:** AX5 pass — numerals scale-to-fit (no clip), body/label scale, header non-clipping.
5. **5.2.1 re-check:** disclaimer exact + queryable; no castle/trade dress/character IP; app name intact; launcher icon unchanged.
6. **Mechanical trade-dress backstop (required — this is a resubmission build).** A deterministic grep/build-script check over the **app + widget SHIPPING targets only** (exclude `#Preview` blocks and the preview device-frame shadow) asserting these render patterns are gone: `HeroMarkView(`, `WishStarShape`, `WidgetWishStarShape`, `GradientBackgroundView`, `StarFieldView`, `CelebrationOverlay`, `.ultraThinMaterial`, `.emoji` used inside a `View`, a background `LinearGradient`, and `.shadow(`. Rationale: deleted *types* are compiler-proven gone, but `.emoji` (the property survives as data) and any net-new gradient/shadow/material are NOT type-guarded — this catches them. Scope to shipping targets so preview false-positives don't turn it into ignored theater. A non-empty match fails the gate.
7. QA + PM produce release testing notes; any code fix loops back through code review before sign-off.

---

## Risks & watch-items

- **`ParkThemeProvider` — RESOLVED at the gate (option b).** Kept as a thin park-identity holder so `HomeViewModel` and its init are untouched; only the gradient/time-of-day *surface* is deleted. Migrate the views that read it for `accentColor`/`currentTheme` to `trip.primaryPark` + `panelColor(for:)`. No wholesale provider deletion (that would break the presentational-only guardrail). See Phase 1e.
- **Tracking/leading in SwiftUI** doesn't map 1:1 to CSS — the Phase-1c helper must be validated visually against `screenshots/01` before screens depend on it, or every numeral drifts.
- **Widget token membership** — if the new foundation files aren't added to the widget target, the build breaks or the widget silently diverges. Resolve in Phase 5, prefer shared membership.
- **`ImageRenderer` colorScheme** — share cards will export wrong colours if the scheme isn't threaded explicitly.
- **Scope creep on "presentational only"** — the milestone screen (new UI + route) is the one sanctioned exception; resist adding others.

---

## Discrepancies found vs the handoff (flag at the gate)

1. **`CastleSilhouetteView.swift` is misnamed** — it contains **no** castle type; it defines `HeroMarkView` / `WishStarShape` / `enum WishStar`. The handoff's "remove `WishStarShape` hero mark" = remove `HeroMarkView` from its 9 call sites + delete this file + the widget's duplicated `WidgetWishStarShape`.
2. **`ParkColorPalette` has no `deep` property** — the `-deep` tone is the existing `backgroundGradientMid1` stop (values match the token file). `panelColor(for:)` uses it directly.
3. **Milestone field is `subtitle`, not "body"**, and there is **no `daysBeforeStart`** (it's `daysOut`). The milestone strip computes passed-thresholds from `Milestone.all` (`daysOut`) + `daysUntilStart`.
4. **Milestone copy is Title Case in source** ("One Month to Go!") but sentence case in the mockups — **RESOLVED at gate: update the source strings to sentence case** (sanctioned copy edit; see Open-question default #5).
5. **`DTDFont` is not custom-font-based** — it already uses `.system(design:.rounded)`, so Outfit→SF Pro Rounded is a token extension, not a font-file addition. Many call sites also hand-roll raw `.system(...)`; the redesign should route them through the new tokens.
6. **Two screens force `.preferredColorScheme(.dark)`** (Settings, AddEditTrip) — must be removed for light-mode to work; the handoff doesn't mention it.
7. **Milestone screen does not exist today** — it's new UI + one new `AppNavigationRouter` route, not a restyle of an existing view.

---

## Post-review deferred tech debt (fast-follow, tracked)

Code review (2026-08-18) cleared the redesign as ship-safe (zero Critical). Two **pure dead-code** cleanups were deliberately deferred out of the ship PR (they touch all 12 palettes / the guardrail-protected ViewModels and have zero user impact). Do these in a separate fast-follow PR:

1. **Dead gradient data on `ParkColorPalette`.** Only `primary` and `backgroundGradientMid1` are live. Delete the orphaned `backgroundGradientStart/Mid2/End`, `accent`, `secondary`, `textOnPrimary`, and the `gradientStops` computed var across all 12 palette definitions; rename `backgroundGradientMid1` → `panelDeep` (it's the dark-panel tone now, not a gradient midpoint) and update `panelColor(for:)`.
2. **`ParkThemeProvider` is now dead.** `setActivePark` is write-only (nothing reads `.park`). Remove `ParkThemeProvider`, `DisneyThemeEnvironment`, and the `setActivePark` calls in `HomeViewModel:97` + `TripDetailViewModel:62` (this finally lets `HomeViewModel`'s themeProvider injection go — the init-signature change that was correctly avoided during the redesign).

The four ship-relevant review findings (California Adventure contrast, MilestoneView error state, unused TripRow, castle code-comment) were fixed in the ship PR.
