# Countdown to Magic — iPad adaptation of the Toy Box system

**Design spec for Phase 4i.** Reuses the existing Toy Box components verbatim. iPad differs from iPhone by **margin, max-width, and column count only** — never by growing components. Tiles keep their radii (22–34), padding (18–24), and type. Flat, one park panel per screen, light + dark, no photography, no mark.

## 0. The one rule that governs everything

> **On iPad, whitespace and column count grow. Components do not.**

A hero panel stretched to iPad width is the failure mode. Instead: the park panel stays a bounded radius-34 tile at roughly its iPhone width; the extra canvas becomes neutral margin and, on three screens, a second neutral column beside it.

And the Toy Box prime directive still holds, now as a build-time invariant:

> **Count the park panels in every navigation state. It is always exactly one.**

(The sanctioned small park uses — the 44px trip-row swatch, checkbox/progress fills — do **not** count. A neutral trip row with a colour swatch is still "one panel." Keep them.)

## 1. How "one park panel per screen" scales — the approach

**Recommended: a size-class hybrid, not a persistent split.** Two layout families, chosen by the container's **width** size class:

| Container width class | Layout family |
|---|---|
| **Compact** (Slide Over, narrow Split View, ~½ portrait multitask) | The iPhone views, unchanged. One scrolling column. |
| **Regular** (full-screen iPad, wide Split View) | Either a **max-width single column** or a **two-column canvas**, per screen (§4). |

**(a) Constrained single column** — form/reading screens (Add Trip, Settings, Welcome, Packing, Milestone). Take the iPhone view verbatim, clamp to **max content width ~680pt**, centre, surplus becomes margin. Zero bespoke iPad code.

**(b) Two-column canvas** — dashboard screens (Home, Trip Detail, Park Dashboard). **Lead column** holds the sole park panel (bounded tile, normal width, on the neutral page). **Trailing column** holds the neutral content that scrolled underneath on iPhone.

### Why this, and what it kills
**The persistent left-hero + right-nav shell in today's `iPadHomeLayout.swift` must go.** In Toy Box the left hero *is* a park panel, so the instant the right pane pushes Trip Detail / Park Dashboard / Add Trip / Milestone (each carrying its own panel), two panels are on screen — the documented bug. So:
- **Home is a self-contained two-column screen.** No detail pane beside it.
- **Trip Detail, Park Dashboard, Add Trip, Milestone are full-width pushes** that replace Home. Each is its own single screen with exactly one panel.
- The lead column is **neutral scaffolding** — do not full-bleed it in park colour (recreates the stretched-panel/gradient pattern). Park colour lives only inside the radius-34 tile.

A true sidebar master-detail is the only other system-legal option, but it collapses to list-first in compact width and throws away the hero-first entry point. Self-contained two-column + full-width pushes is simpler and keeps the hero as the front door.

## 2. Numeral & type scale on iPad
**The numeral scales to its share of the panel, not to screen width.** Hold the iPhone ratio (~40% of panel height), cap at ~45%.

| Numeral | iPhone | iPad (regular width) | Note |
|---|---|---|---|
| Hero (Home) | 118 | **118**, toward ~140 only if the panel grows taller | Panel width ≈ iPhone |
| Screen (Trip Detail, In-park) | 96 | **96** | Holds |
| Stat tile | 40 | **40** | Never grows |
| Milestone | 172 | **220–240** | The exception |

**Milestone is the one that must grow** — the sole full-bleed park screen; 172 looks lost on a 12.9" canvas, so ~220–240 (tracking ≈ −15 to −16), with the type block clamped to a max-width so it reads composed. Everything else (Display 38, Title 24, Heading 23, Body 16, Prose 15, Labels 11–12) is unchanged; Dynamic Type still drives it. Give the dev the rule ("numeral = share of panel height, capped ~45%"), not a fixed iPad number.

## 3. Tokens to add (outer margins + column geometry only)
```
--space-18: 32px;
--space-20: 40px;
--space-24: 64px;
--gutter-screen-ipad: 40px;      /* regular-width outer margin (vs 20 on iPhone) */
--max-content-width:   680px;    /* clamp for family (a) single-column screens */
--col-gap-ipad:        32px;     /* gap between lead and trailing columns */
--panel-col-max:       420px;    /* max width of the panel/lead column in family (b) */
```
**Radii: no additions** (22/26/30/34 carry over). Drive two-column geometry off the **GeometryReader container width, not a fraction of full screen** (the current `geo.size.width * 0.42` is what makes Slide Over fragile):
- Lead column: `min(--panel-col-max, ~40% of container)`.
- Trailing column: remainder minus `--col-gap-ipad`.
- Outer margins: `--gutter-screen-ipad` each side, growing toward `--space-24` on 12.9" landscape.

## 4. Per-screen intent
Legend: **(a)** = constrained single column · **(b)** = two-column canvas.

| Screen | Regular-width family | Portrait | Landscape | Compact multitask |
|---|---|---|---|---|
| **Home** | (b) | Panel + 2 stat tiles in lead col; daily card + trip list in trailing col | Wider trailing col; trip list may go 2-up | iPhone view |
| **Trip Detail** | (b) | Panel + 3 metric tiles in lead col; packing/notes/tips in trailing col | Same | iPhone view |
| **Park Dashboard** | (b) | Deep-tone summary panel + selector/sort in lead col; attraction list in trailing col | List can go 2-column | iPhone view |
| **Packing List** | (a) | Summary panel + category cards, clamped 680 | Centred | iPhone view |
| **Add Trip** | (a) | Form clamped 680, resort panel full width of that column | Same | iPhone view (sheet/push) |
| **Settings** | (a) | Clamped 680, centred | Same | iPhone view |
| **Welcome** | (a) | 3×2 tile grid + copy, clamped 680 | Grid may sit beside copy at ≥landscape width | iPhone view |
| **Milestone** | (a), full-bleed | Full-bleed panel, numeral 220–240, content block clamped | Centred | iPhone view |

**Rotation / Stage Manager** are handled for free: layout keys off container width class and the split is computed from `GeometryReader`, so dragging a window narrow crosses into compact (iPhone view) and widening returns to two-column. No orientation code.

## 5. What doesn't translate — and the fix
| iPhone assumption | Breaks on iPad because | Resolution |
|---|---|---|
| Persistent left-hero + right-NavigationStack | Two park panels on screen when the right pane shows a detail screen | Delete it. Home = self-contained two-column; detail screens = full-width pushes |
| Full-bleed left column | A full-bleed *park* column is a stretched-panel/gradient pattern | Column is neutral page; panel is a bounded radius-34 tile inside it |
| `geo.size.width * 0.42` split | Fraction-of-full-screen wrong under Slide Over / Stage Manager | Compute columns from GeometryReader container width; cap lead at `--panel-col-max` |
| 118pt hero as a fixed number | Fixed number reads lost (full-bleed) or unchanged (contained) | Numeral = share of panel height, capped ~45%; contained ⇒ 118/96 hold; milestone ⇒ 220–240 |
| One 20pt-gutter column fills width | Empty stretched panel; prose line lengths too long | Family (a) clamp to 680; family (b) second neutral column absorbs width |
| Single column always | Wastes trailing half on dashboard screens | Two-column canvas for Home / Trip Detail / Park Dashboard only |

**Also:** the existing `iPadHomeLayout.swift` still imports the pre-Toy-Box `GradientBackgroundView` + `StarFieldView` + `HeroMarkView` — removed by the redesign; the iPad rewrite sits on flat `--bg` like every Toy Box screen. No gradient, star field, or glow.

## Build summary
1. Add the six iPad tokens (§3) to the Toy Box token layer.
2. Branch on **container width size class**: compact → existing iPhone views unchanged.
3. Regular width, five screens (Add Trip, Settings, Welcome, Packing, Milestone): wrap iPhone view in `.frame(maxWidth: 680)` + centre. No new layouts.
4. Regular width, three screens (Home, Trip Detail, Park Dashboard): two-column `HStack` off `GeometryReader`; lead column capped 420 holds the sole panel; trailing column holds the neutral stack.
5. Delete the gradient/star-field/hero-mark iPad shell; rebuild flat.
6. Numerals: drive off panel-height proportion (cap ~45%); milestone 220–240, others hold.
7. Assert the invariant per nav state: exactly one park panel.
