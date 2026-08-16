# Countdown to Magic — Design System

Countdown to Magic is an unofficial iOS + Android app that turns the wait before a Disney park trip into part of the trip. Families create countdowns, get one piece of curated content a day, keep a park-aware packing list, and — once they are inside the gates — see live wait times.

This design system captures the **Toy Box** visual direction chosen for the app's redesign, and grounds every value in the app's own source.

## Sources

| Source | Notes |
|---|---|
| GitHub `joxenford/Days-Til-Disney` (branch `main`) | Primary source of truth. See `github.md` at the project root for the sync receipt and screen map. |
| `ios/Days-Til-Disney/` (SwiftUI) | Screens, components, theme engine, models |
| `shared/design/color-palettes.md` | Palette intent + the WCAG AA (4.5:1) commitment this system holds itself to |
| `Core/Models/ParkColorPalette.swift` | Every park hex in `tokens/colors.css` is copied verbatim from here |
| `Core/Models/Milestone.swift` | The eight milestones: 100, 50, 30, 14, 7, 3, 1, 0 |
| `Engine/LiveParkData/ParkLiveData.swift` | `LiveAttraction` / `AttractionStatus` — the only live fields that exist |

Readers without repo access: the design files in this project (`Countdown to Magic - Toy Box.dc.html`, `Current App - Recreation.dc.html`) show the before and after in full.

## Index

- `styles.css` — the single entry point; imports everything below
- `tokens/` — `fonts`, `colors`, `typography`, `spacing`, `radii`, `elevation`
- `components/core/` — Button, IconButton, Chip, SectionLabel, ProgressBar, Checkbox, Toggle, SegmentedControl
- `components/countdown/` — ParkPanel, CountdownNumeral, StatTile, TripRow, WaitPill, MilestoneStrip
- `ui_kits/ios_app/` — click-through app recreation (9 screens) + `extras.html` (widgets, share cards)
- `ui_kits/website/` — marketing site recreation
- `guidelines/` — foundation specimen cards
- `SKILL.md` — Agent Skills entry point

## Content fundamentals

**Voice: warm, plain, a little wry — never squealy.** The app is for adults planning a trip that children are excited about, so the copy is excited *with restraint*.

- **Sentence case everywhere** except small uppercase labels (`PACKED`, `NEXT UP`, `MAGIC KINGDOM`). Never Title Case On Buttons.
- **Second person, implied.** "Add your first trip", "you're there!" — the app talks to one family. Never "I" or "we".
- **Numbers do the talking.** "45 days", "12/38", "Day 3 of 7". Copy around a number stays short so the number stays loud.
- **Exclamation marks: at most one per screen**, reserved for genuine arrival moments ("Day 3 of 7 — you're there!", "One month to go!").
- **Specific over generic.** "Break in the shoes now — ten miles a day is an ordinary Tuesday here" beats "Wear comfortable shoes".
- **No emoji.** The Swift source uses park emoji as a data field (`DisneyPark.emoji`); the Toy Box direction replaces those with park colour, so emoji do not appear in the UI.
- **Empty states are invitations, not apologies:** "Nothing to count down to — yet."
- **Milestone copy comes from `Milestone.swift`.** Do not invent thresholds or rename them.
- **Legal line, verbatim, on Settings:** "Countdown to Magic is an unofficial app. Not affiliated with, endorsed by, or sponsored by The Walt Disney Company."

## Visual foundations

**The one big idea:** each screen has exactly **one park-coloured panel**. Everything else is neutral. The old build filled every screen with a four-stop park gradient; this system spends that colour once, which makes it mean something.

- **Colour.** Park primaries verbatim from `ParkColorPalette.swift`. **Fill a panel with a `--park-panel-*` role, never a raw primary** — the role resolves to the primary on light and the `-deep` variant (that file's `backgroundGradientMid1`) on dark, so no screen decides that for itself. Gold `#E8C84A` is the single accent — daily content, milestones, progress in dark mode. Status colours only on wait times.
- **No gradients. No blur. No translucency.** Separation comes from surface steps: page → tile → raised. The old `.ultraThinMaterial` glass is gone.
- **Type.** Outfit for everything structural (labels through numerals), Karla for sentences. Numerals are Outfit 800 with heavy negative tracking (118/-7 hero, 96/-6 screen, 40/-2 stat). Prose never exceeds 17px; labels never exceed 12px.
- **Shape.** Radii are generous and consistent: 9 (check), 14 (icon button), 16 (chip), 22–26 (tile), 30 (card), 34 (park panel), 999 (pill). Nothing square, nothing sharper than 9px.
- **Layout.** 20px screen gutter, 12px between tiles, tiles at 18–26px inner padding. Stat tiles come in pairs. Content is a single scrolling column — no grids of more than two.
- **Elevation.** Flat. The only shadow in the system is the device frame in previews (`--shadow-frame`).
- **Backgrounds.** Flat colour only: no photography, no illustration, no pattern, no starfield. (The old build's animated star field and glow shadows are intentionally dropped.)
- **Borders.** Used sparingly: 2px hairline on an unchecked box, 1.5px white-alpha outline for an unselected row inside a park panel. Never a 1px border as decoration.
- **Motion.** Sparing and functional: the countdown numeral gets a single spring scale bump when the day flips (0.4s response, 0.6 damping — matching `CountdownHeroView`), progress bars animate their width on change, screens cross-fade. No bounce on entry, no parallax, no confetti — the milestone screen is a full-screen park panel, not a particle system.
- **States.** Press = 96% scale on tiles and buttons, no colour change. Hover is irrelevant on device; in web recreations use a 4% surface darkening. Selected = ink fill inverting to page colour (chips, segmented control) — never a colour swap. Disabled = 45% opacity.
- **Transparency.** Only inside a park panel: `rgba(255,255,255,.18)` for chips and badges, `.78–.85` for secondary text on colour. Never over a photo, never as a scrim.
- **Theme-aware roles.** `--accent` paints the park panel and is deliberately dark; anything *interactive* (toggle track, checkbox fill, progress) uses `--accent-interactive`, which becomes gold in dark mode, with `--on-accent` for the glyph on top and `--knob` for a switch knob. Gold label text uses `--gold-label`, and wait-time text uses `--wait-short / --wait-mid / --wait-long` — never `--gold-label-on-light` or a raw `--status-*` value as text colour.
- **Contrast.** Every text colour clears WCAG AA 4.5:1 against its own surface, per `color-palettes.md`. Muted text is `#5F5F66` on light and `#9A99A2` on dark. Coloured wait times are set at 19px/700 so they qualify as large text.

## Iconography

**The system is almost icon-free, on purpose.** The old build leaned on ~30 SF Symbols; the Toy Box direction replaces nearly all of them with type, colour and shape.

- **What remains:** typographic glyphs inside `IconButton` — `+` (add), `‹` (back), `•••` (settings), `↻` (refresh), `›` (row disclosure), `✓` (checked). These are set in Outfit, not an icon font.
- **Park identity is colour, not a mark.** A 44px park-coloured rounded square stands where an icon would go.
- **No logo exists in the source** — the repo ships an app icon built from a "Wish" `Shape` path in Swift, not a wordmark. So the brand appears as plain type: "Countdown to Magic" in Outfit 700 at 19px. **Nothing in `assets/` was drawn for this system**, and no mark should be invented.
- **No emoji, no illustration, no hand-drawn SVG.** If a future screen genuinely needs a glyph set, use Lucide at 1.5px stroke and flag the addition here.

## Intentional additions

- `SectionLabel` and `SegmentedControl` are extracted as components because the pattern repeats across six screens; in the Swift source they are inline modifiers rather than named views.
- `MilestoneStrip` is new UI (the app previously surfaced milestones only as a notification + celebration overlay). It renders the existing `Milestone.all` data — no new thresholds.

## Caveats

- **Fonts are substitutions.** The app uses SF Pro Rounded (system, not redistributable). `tokens/fonts.css` loads Outfit + Karla from Google Fonts as the closest available match. Swap in licensed binaries with local `@font-face` when you have them.
- **Component cards are static specimens.** They render the real tokens from `styles.css` but do not mount the compiled bundle, so no namespace is assumed.
- **Android is not covered.** Only the iOS source was read; the Compose implementation in `android/` should be reviewed before this system is applied there.
- **`privacy.html` is not recreated** in the website kit — it is long-form legal copy, quick to add on request.
