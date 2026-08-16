# Implementation Plan: Rebrand "Days Til Disney" → "Countdown to Magic" (App Store 5.2.1 Remediation)

**Branch:** `rebrand-countdown-to-magic`
**Project root:** `/Users/jamesoxenford/Developer/DaysTilDisney/ios/Days-Til-Disney/`
**Status:** Draft for plan-approval gate. Do NOT begin implementation until approved.

## Objective

Strip Disney trademarks and trade dress from user-facing surfaces to clear a 5.2.1 rejection, without touching internal types, bundle identifiers, park data, or factual trivia. This is a **branding/labeling** change, not a data-model change.

---

## The Legal Cut-Line (read before touching anything)

Every "Disney" hit in the codebase falls into exactly one of three buckets. **Only Bucket C changes.** This classification IS the deliverable that prevents over-scoping — an implementer must not "helpfully" rename anything in Bucket A or B.

### Bucket A — Internal / invisible. KEEP. Renaming breaks things.
Users never see these; several are load-bearing for deployed installs and stored data.

| Identifier | Location | Why keep |
|---|---|---|
| `DisneyResort`, `DisneyPark` (type names) | `Core/Models/DisneyResort.swift`, `DisneyPark.swift` | Internal types; no legal benefit to renaming |
| `DisneyThemeEnvironment`, `Color.disneyGold` (#C9A84C), `Color.magicSparkle` | `DesignSystem/DisneyThemeEnvironment.swift`, `Core/Extensions/Color+Hex.swift:74` (used in ~10 files) | Internal token names; invisible |
| `castleAssetName` property | `DisneyResort.swift:69`, `DisneyPark.swift:88`, `Engine/Theme/ParkTheme.swift` | Internal property (see "castleAssetName fate" below) |
| **Widget `kind = "DaysTilDisneyWidget"`** | `DaysTilDisneyWidget/DaysTilDisneyWidget.swift:58` | **Changing it orphans every widget users have already placed** |
| **`group.com.thinkupllc.Days-Til-Disney`** (App Group) | `Core/Persistence/SwiftDataContainer.swift:32` | **Breaks app↔widget shared storage** |
| **`iCloud.com.thinkupllc.Days-Til-Disney`** (CloudKit container) | `SwiftDataContainer.swift:37` | **Breaks existing users' iCloud sync** |
| **`Days-Til-Disney.sqlite`** (store filename) | `SwiftDataContainer.swift:40` | **Breaks existing users' local data** |
| Bundle IDs `com.thinkupllc.Days-Til-Disney(*)` | `project.pbxproj` (615/650/etc.) | Breaks signing/provisioning; invisible |
| Target/module name, preview names, `#Preview("Disneyland - Dawn")` | pbxproj, various | Invisible |

### Bucket B — Factual / nominative real-world names. KEEP (per PM scope decision).
Naming a real destination the user is traveling to is nominative use and stays. **This includes the park picker feature and its palette — reframe copy only, never remove the feature or data.**

- Resort/park `displayName`s: "Walt Disney World", "Disneyland Paris", "Tokyo DisneySea", etc. — `DisneyResort.swift:16-21`, `DisneyPark.swift:26-33`
- `ParkColorPalette` (12 park colors) and the park picker — `Core/Models/ParkColorPalette.swift`, `Features/AddEditTrip/Components/ParkSelectorView.swift`. **KEEP feature + colors + types.**
- Factual daily trivia about real, public attractions/history: "Walt Disney purchased the land…" (`DailyContent.swift:154`), ride names like "Big Thunder Mountain Railroad", etc.
- Sample/preview trip name "Disneyland Summer 2024" (`Trip.swift:150`) — factual example, keep.

### Bucket C — Decorative use of the mark in the app's OWN voice. CHANGE.
The app leaning on "Disney" as *its own* branding/theme, plus all castle trade dress and character-resembling art. Enumerated in the phases below. **Borderline copy items are flagged `[LEGAL-REVIEW]` — list them, do not pre-decide; the approval gate + legal resolve them.**

---

## Phase 1 — App display name (both targets)

The main app target has **no** `INFOPLIST_KEY_CFBundleDisplayName`; it falls back to `PRODUCT_NAME=$(TARGET_NAME)` → home-screen name is currently "Days-Til-Disney". The widget has an explicit key AND a separate in-code gallery name — **both** must change.

**Files touched:**
- `Days-Til-Disney.xcodeproj/project.pbxproj`
  - **Add** `INFOPLIST_KEY_CFBundleDisplayName = "Countdown to Magic";` to the app target's Debug and Release configs (near lines 602 and 637, alongside the other `INFOPLIST_KEY_*` entries). Do this in Xcode's build-settings UI to keep the pbxproj well-formed.
  - **Change** widget `INFOPLIST_KEY_CFBundleDisplayName` from `DaysTilDisneyWidget` → `"Countdown to Magic"` at lines **420** and **451**.
- `DaysTilDisneyWidget/DaysTilDisneyWidget.swift`
  - Line **83**: `.configurationDisplayName("Days 'Til Disney")` → `"Countdown to Magic"` (this is the widget-gallery name; distinct from the plist key).
  - Line **84**: `.description("Count down the days to your Disney trip.")` → neutral copy, e.g. `"Count down the days to your next trip."`

**Do NOT touch:** bundle IDs, `kind`, App Group / CloudKit / sqlite identifiers (Bucket A).

**Checkpoint 1:** Build both targets; confirm home-screen icon label and widget-gallery entry read "Countdown to Magic". Existing placed widgets still resolve (kind unchanged).

---

## Phase 2 — Remove the castle trade dress

There are **no castle image assets** in the catalogs — the castle is drawn programmatically. `CastleSilhouetteView` looks up `park.castleAssetName`, finds no image, and always renders `FallbackCastleShape` (a Cinderella-Castle-inspired path). The widget duplicates this as `WidgetFallbackCastleShape`. Removing the trade dress = replacing these shapes/usages with the design team's **new neutral mark** (see Design Handoff).

**Files touched (shape definitions):**
- `DesignSystem/Components/CastleSilhouetteView.swift` — replace `FallbackCastleShape` (lines 71-143) and the `Image(park.castleAssetName)` branch with the new neutral mark. Rename the view to a neutral name (e.g. `HeroMarkView`) at the call sites, OR keep the view name and swap only the shape (implementer's call — lower-churn is swap-in-place).
- `DaysTilDisneyWidget/DaysTilDisneyWidget.swift` — replace `WidgetFallbackCastleShape` (line 365) and `WidgetCastleSilhouette` (line 347). **Sync note in the file (lines 360-364) is now moot** once both are neutral marks; update or delete it. Widget extension cannot import the main target, so the mark stays duplicated.

**Files touched (call sites — replace castle hero with neutral mark):**
- `Features/Home/HomeView.swift:251`
- `Features/Home/iPadHomeLayout.swift:104, 213`
- `Features/Home/Components/CountdownHeroView.swift:68-69`
- `Features/TripDetail/TripDetailView.swift:101, 133-134`
- `Features/TripDetail/ShareCountdownCard.swift:42-43` (share-image watermark — regenerate any cached share art)
- `Features/Splash/SplashView.swift:29-36` (animated castle in launch splash)
- `Features/Onboarding/WelcomeView.swift:34-46` (welcome hero + sparkle constellation)
- `Widget` internal uses at `DaysTilDisneyWidget.swift:120, 172, 333`
- `Features/Settings/SettingsView.swift:77` — `Image(systemName: "castle.fill")` in the About row. This is Apple's generic SF Symbol, **not** Disney's castle (no IP risk), but change it for brand consistency to a neutral glyph (e.g. `sparkles` / `wand.and.stars`).

**castleAssetName fate — decided (design delivered a universal mark):**
The "Wish" shooting-star mark is universal, so `castleAssetName` becomes dead code. Delete it at **all four sites** (deleting only the two model properties will not compile — it is a protocol requirement with a default impl):
1. `Engine/Theme/ParkTheme.swift:8` — protocol requirement
2. `Engine/Theme/ParkTheme.swift:20` — default implementation
3. `Core/Models/DisneyResort.swift:69` — model property
4. `Core/Models/DisneyPark.swift:88` — model property

Then delete its three tests (`DisneyResortTests.test_castleAssetName_allNonEmpty`, `test_waltDisneyWorld_castleIsCinderella`; `DisneyParkTests.test_castleAssetName_delegatesToResort`).

**Checkpoint 2:** No castle silhouette renders anywhere — home hero, iPad layout, trip detail, share card, splash, onboarding, all widget families, Settings About. Visual pass required (see Verification).

---

## Phase 3 — Remove character-resembling content

Per PM scope: remove only content that **resembles protected art or characters** or uses a character as **decoration**. Factual trivia about real attractions/history **stays** (Bucket B).

**Files touched:**
- `Core/Models/DefaultPackingItems.swift:46` — `Template(name: "Mickey ears / Disney ears", …)` → neutral, e.g. `"Themed ears / headband"`. (Seed data only; does not migrate existing users' saved lists — acceptable.)
- `Features/Home/Components/DailyContentCardView.swift:116` — `source: "Disney Official"` implies endorsement. Change to neutral or remove. Note: this is **preview/sample only**; the shipped `daily_content.json` has `source: null` on all 365 entries.
- `Resources/daily_content.json` — **content-audit sub-phase, separate owner (content + legal).** 365 live entries loaded by `LocalContentRepository.swift:20`. Raw hits: 34 "Mickey", 20 "Cinderella", 5 "Minnie", 4 "Elsa", 1 "Goofy", 119 "Walt Disney". **Rule:** factual/nominative references to real, public rides/history/characters STAY; only entries that read as decorative character use or resemble protected art are removed/reworded. Most "Walt Disney"/ride-name trivia is factual and stays. Do **not** blanket-delete by keyword.

  **AUDIT OUTCOME (2026-08-16): no changes — all 365 entries kept.** Only 59 entries reference characters/franchises; of those ~52 are factual descriptions of real, publicly-named attractions/park history (nominative use) and ~7 are film/character-brand trivia (also nominative, legally defensible). **Zero entries reproduce protected artwork or present characters as the app's own creative content**, so nothing requires removal on IP grounds. Head of Agency reviewed the 7 film/character-centric entries (`3fb9d0b9`, `402bbffe`, `0578d45f`, `515e1765`, `09fb7383`, `bdca15d9`, `685540bf`) and elected to keep all. Delivery Lead's audit is a content/product judgment, not a legal opinion — final legal sign-off remains the Head of Agency's if counsel review is desired.

**Checkpoint 3:** Content owner + legal sign off on the `daily_content.json` audit diff. Packing seed and preview source updated.

---

## Phase 4 — Rebrand user-facing copy in the app's own voice (Bucket C strings)

These use "Disney" as the app's *own* branding/theme (not a factual park name). Replace with neutral voice ("Magic", "the parks", "your trip"). **PM/Head-of-Agency decision: all `[LEGAL-REVIEW]` items are APPROVED for neutralization** (conservative posture for this resubmit) — implement them, no further sign-off needed.

**Change (app's own identity/voice):**
- `Features/Splash/SplashView.swift:50` — `Text("Disney")` title (paired with "Days Til" at line 46) → "Countdown to Magic" wordmark. Update `accessibilityLabel` line 61.
- `Features/Settings/SettingsView.swift:74` — About row `Text("Days Til Disney")` → "Countdown to Magic".
- `Features/Home/HomeView.swift:214`, `iPadHomeLayout.swift:111, 385` — `Text("Days 'Til Disney")` header → "Countdown to Magic".
- `Features/TripDetail/ShareCountdownCard.swift:168` — `Text("Days Til Disney")` share footer → "Countdown to Magic".
- `DaysTilDisneyWidget/DaysTilDisneyWidget.swift:329` — `Text("Days 'Til Disney")` → "Countdown to Magic"; accessibility labels at 260, 304, **341** (`"Days Til Disney. Add a trip to start your countdown."` — VoiceOver-visible app-voice branding).
- `DaysTilDisneyWidget/SelectTripIntent.swift` — widget-configuration ("Edit Widget") + Shortcuts app, app's own voice:
  - Line 10: `typeDisplayRepresentation = "Disney Trip"` → `"Trip"`
  - Line 42: `IntentDescription("Choose which Disney trip to count down to.")` → `"Choose which trip to count down to."`

**Change (decorative generic "Disney" as destination stand-in):**
- `Core/Models/Milestone.swift:54` — "One sleep until Disney magic…" → "One sleep until the magic…"
- `Core/Extensions/Date+Countdown.swift:52, 54, 56` — "…your Disney trip" → "…your trip"
- `Features/Home/Components/CountdownHeroView.swift:240` — `Text("You're at Disney!")` → "You're at the parks!" `[LEGAL-REVIEW]`
- `Features/Home/HomeView.swift:265`, `iPadHomeLayout.swift:225` — "Add your first Disney trip…" → "Add your first trip…"
- `Features/Onboarding/WelcomeView.swift:61` header (see Phase 4 wordmark), `:88` accessibilityLabel "Create your first Disney trip" → "…first trip".
- `Features/TripDetail/TripDetailView.swift:412` — `Text("Disney Tips for Your Trip")` → "Tips for Your Trip".
- `Engine/Notifications/MilestoneNotificationManager.swift:190, 195, 215` — "One Month Until Disney!", "Days to Disney!", "Sweet Disney dreams" → neutral ("…Until Your Trip!", "…Days to Go!", "Sweet dreams"). `[LEGAL-REVIEW]` on tone.
- `DaysTilDisneyWidget/DaysTilDisneyWidget.swift:301` — `Text("Add a Disney trip!")` → "Add a trip!"; `:319` accessibility "until your Disney trip." → "until your trip."

**Keep (Bucket B — factual, do NOT change):** all resort/park `displayName`s; `Trip.swift:150` sample "Disneyland Summer 2024"; factual trivia bodies.

**Checkpoint 4:** Legal reviews the `[LEGAL-REVIEW]` list and the full Bucket C diff. Confirm no factual park name (Bucket B) was swept up.

---

## Phase 5 — App icon

Replace Disney-branded icon with the new design (handoff from design).

**Files touched:**
- `Days-Til-Disney/Assets.xcassets/AppIcon.appiconset/` — `AppIcon.png`, `AppIcon-Dark.png`, `AppIcon-Tinted.png` (+ `Contents.json` if slot layout changes).
- `DaysTilDisneyWidget/Assets.xcassets/AppIcon.appiconset/` — widget icon set.

**Blocked on Design Handoff.** No new art invented here.

---

## Phase 6 — In-app disclaimer

Add to Settings → About, as a static footer/row (no ViewModel change → no `SettingsViewModelTests` impact).

**File touched:** `Features/Settings/SettingsView.swift` — add to the About `Section` (around lines 96-104):
> "Countdown to Magic is an unofficial app. Not affiliated with, endorsed by, or sponsored by The Walt Disney Company."

Prefer a `Section` `footer:` or a plain `Text` row with `.font(DTDFont.caption)` `.foregroundStyle(.secondary)`. Add an `accessibilityIdentifier` (e.g. `"about.disclaimer"`) to support a UI-test assertion.

**Checkpoint 6:** Disclaimer visible in Settings; wording matches exactly.

---

## Phase 7 — Info.plist / launch screen / asset sweep (verification, mostly no-op)

- **Widget `Info.plist`** (`DaysTilDisneyWidget/Info.plist`): contains only `NSExtension` — nothing to change (display name is in pbxproj, Phase 1).
- **Launch screen:** OS launch screen is **generated** (`INFOPLIST_KEY_UILaunchScreen_*`, solid `LaunchBackground` color, no castle/name) — **nothing to do; state explicitly so no one hunts for a storyboard.** Branding lives in in-app `SplashView` (handled Phase 2 & 4).
- **Asset catalogs:** confirm no lingering castle/name art beyond the app icons (Phase 5). Current catalogs hold only `AppIcon`, `AccentColor`, `LaunchBackground`, `WidgetBackground` — clean.

---

## Design Handoff (external dependency — gates Phases 2 & 5)

Produced in parallel. Plan references, does not invent, art. Handoff must specify:
1. New neutral hero mark (vector/shape or asset) to replace `FallbackCastleShape` / `WidgetFallbackCastleShape`.
2. Whether the mark is **universal or per-park** (decides `castleAssetName` fate, Phase 2).
3. New app-icon PNGs for both targets (Phase 5).

Until delivered, implement structure against a placeholder neutral shape behind a clearly-marked TODO.

**Design direction delivered:** "Wish" shooting-star mark (four-point sparkle + comet arc), universal (not per-park), "Twilight" palette `#12102E → #1E1B4B → #4C1D95 → #7C3AED` with marigold `#FFC93C` accent. Universal mark → `castleAssetName` becomes dead code (Phase 2, universal branch).

---

## Review Checkpoints (summary)

1. Display names correct, widgets still resolve (kind unchanged).
2. Zero castle renders anywhere (visual pass).
3. Content + legal sign-off on `daily_content.json` audit.
4. Legal sign-off on Bucket C copy + `[LEGAL-REVIEW]` items; no Bucket B swept up.
5. Icon replaced (both targets).
6. Disclaimer present and exact.
7. Final full-app visual QA pass before submission.

---

## Risks

- **App Store Connect listing (out of repo, release blocker):** A perfect binary is re-rejected under 5.2.1 if the **store name, screenshots (`screenshots/` dir exists), subtitle, or description** still show the castle or "Days Til Disney". **Owner: Head of Agency** (applies the new metadata copy + re-shot screenshots directly in ASC). Not in this repo's scope but a hard release dependency — the binary must not be submitted until the listing is scrubbed.
- **Deployed-widget / user-data breakage:** Renaming `kind`, App Group, CloudKit container, or sqlite name (Bucket A) orphans placed widgets and existing users' data/sync. Guard against well-meaning renames in review.
- **Design handoff blocks Phases 2 & 5** — critical path; placeholder mitigates but final art is required before submission.
- **Share-card cache:** old castle share images may be cached; regenerate/verify after Phase 2.
- **Over-scope drift:** the temptation to "remove all Disney" would gut Bucket B (park picker, palette, factual trivia) which the PM has explicitly kept. Classification table is the guardrail.

---

## Test / Verification

**Unit-test impact is small — verification is primarily visual.**

- `DisneyResortTests` / `DisneyParkTests`: only the **`castleAssetName` tests** break, and only if you touch that property (Phase 2 decision). With the universal mark, delete the 3 named tests with the property. `displayName` tests are Bucket B — **unchanged**.
- `SettingsViewModelTests`: only checks `appVersion` format (lines 156-163). Disclaimer as static `Text` → **no change**. Do not route the disclaimer through the ViewModel.
- Other suites (Home/TripDetail/AddEditTrip VM, repositories, milestones): unaffected — no type/logic changes.

**Primary verification = visual/UI pass** (use the `ios-ui-testing` skill / XCUITest against the simulator):
1. No castle silhouette in: home hero, iPad layout, trip detail, share card, splash, onboarding, all widget families, Settings About.
2. App display name + widget-gallery name read "Countdown to Magic".
3. Disclaimer visible in Settings About (assert on `accessibilityIdentifier "about.disclaimer"`).
4. No Disney word-mark in the app's own voice (Bucket C) remains; Bucket B park names still present in picker.
5. New app icon renders (both targets).
6. Placed widgets from a pre-rebrand build still resolve (kind unchanged) — regression check.

Run `xcodebuild test` for the unit suites plus the visual/UI pass before submission.

---

## Critical Files for Implementation
- `ios/Days-Til-Disney/Days-Til-Disney.xcodeproj/project.pbxproj` (display names — Phase 1)
- `ios/Days-Til-Disney/Days-Til-Disney/DesignSystem/Components/CastleSilhouetteView.swift` (castle shape — Phase 2)
- `ios/Days-Til-Disney/DaysTilDisneyWidget/DaysTilDisneyWidget.swift` (widget name, castle shape, copy — Phases 1/2/4)
- `ios/Days-Til-Disney/Days-Til-Disney/Features/Settings/SettingsView.swift` (About text, castle glyph, disclaimer — Phases 2/4/6)
- `ios/Days-Til-Disney/Days-Til-Disney/Resources/daily_content.json` (character-content audit — Phase 3, largest-labor item)
