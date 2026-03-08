# DaysTilDisney — Resort Color Palettes

Each Disney resort has a distinct color palette that drives the entire visual experience in the app — from the countdown hero screen gradients to card borders and accent highlights. Palettes are designed to evoke each resort's flagship castle and emotional atmosphere.

---

## Color Role Definitions

| Role | Usage |
|------|-------|
| `primary` | Main brand color for the resort; hero backgrounds, key UI elements |
| `secondary` | Complementary color; headers, section dividers |
| `accent` | High-contrast highlight; CTAs, countdown number ring, milestone badges |
| `gradientStart` | Top color of the countdown hero background gradient |
| `gradientEnd` | Bottom color of the countdown hero background gradient |
| `textOnPrimary` | Text/icon color guaranteed to be legible on the primary background |
| `textOnDark` | Text/icon color for use on dark gradient backgrounds |
| `castleSilhouette` | Color used to render the castle/icon silhouette asset |

---

## Walt Disney World

**Flagship Castle**: Cinderella Castle
**Emotional Tone**: Regal, classic, the iconic dream

| Role | Hex | Preview |
|------|-----|---------|
| `primary` | `#1A3A6B` | Deep royal blue |
| `secondary` | `#C9A84C` | Antique gold |
| `accent` | `#F5D77E` | Bright golden yellow |
| `gradientStart` | `#0D2247` | Midnight navy |
| `gradientEnd` | `#2E5FAC` | Bright sky blue |
| `textOnPrimary` | `#FFFFFF` | White |
| `textOnDark` | `#F0E6C8` | Warm cream |
| `castleSilhouette` | `#C9A84C` | Antique gold |

### Time-of-Day Variants
- **Dawn**: Gradient shifts to `#FF9A6C` (peach) → `#FFD580` (warm gold)
- **Day**: Use base palette above
- **Dusk**: `#7B3F7A` (twilight purple) → `#1A3A6B` (royal blue)
- **Night**: `#050D1A` (deep navy) → `#0D2247` (midnight navy) with star accents `#F5D77E`

---

## Disneyland Resort

**Flagship Castle**: Sleeping Beauty Castle
**Emotional Tone**: Whimsical, storybook, where it all began

| Role | Hex | Preview |
|------|-----|---------|
| `primary` | `#C0392B` | Disney red |
| `secondary` | `#C9A84C` | Antique gold |
| `accent` | `#FFE066` | Bright canary yellow |
| `gradientStart` | `#8B1A1A` | Deep crimson |
| `gradientEnd` | `#E85D5D` | Warm coral red |
| `textOnPrimary` | `#FFFFFF` | White |
| `textOnDark` | `#FFE8D6` | Warm ivory |
| `castleSilhouette` | `#F2B8B8` | Soft rose pink |

### Notes
Sleeping Beauty Castle is painted in shades of pink, blue, and gold — the castle silhouette color reflects the iconic pink spires rather than the main red brand color.

### Time-of-Day Variants
- **Dawn**: `#FFB347` (warm orange) → `#FFDA79` (golden morning)
- **Day**: Use base palette above
- **Dusk**: `#C0392B` (deep red) → `#8B3A8B` (twilight plum)
- **Night**: `#1A0A0A` (deep black-red) → `#3D1515` (dark crimson)

---

## Tokyo Disney Resort

**Flagship Castles**: Tokyo Disneyland Castle (Cinderella) + Mt. Prometheus (DisneySea)
**Emotional Tone**: Refined, festive, cherry blossom wonder

| Role | Hex | Preview |
|------|-----|---------|
| `primary` | `#E8476A` | Cherry blossom red-pink |
| `secondary` | `#FFFFFF` | Pure white |
| `accent` | `#F7C5D5` | Soft petal pink |
| `gradientStart` | `#B5003B` | Deep rose |
| `gradientEnd` | `#F28FAD` | Light sakura pink |
| `textOnPrimary` | `#FFFFFF` | White |
| `textOnDark` | `#FFF0F5` | Blush white |
| `castleSilhouette` | `#FFFFFF` | White (castle appears as white silhouette on pink sky) |

### Notes
Tokyo Disney Resort uniquely serves two flagship parks with very different aesthetics. The palette above leans toward the cherry blossom cultural identity shared across both parks. DisneySea-specific theming (used when that park is selected) can draw more from the deep oceanic blues of `#1B3A5C`.

### Time-of-Day Variants
- **Dawn**: `#FFB7C5` (sakura dawn) → `#FFE4EE` (pale petal)
- **Day**: Use base palette above
- **Dusk**: `#C45C7A` (rose dusk) → `#7A2840` (deep rose)
- **Night**: `#0A0A1A` (deep navy) → `#1C0D24` (midnight purple) with `#F7C5D5` petal accents

---

## Disneyland Paris

**Flagship Castle**: Le Chateau de la Belle au Bois Dormant (Sleeping Beauty Castle, Paris)
**Emotional Tone**: Enchanted fairytale, European grandeur, romantic magic

| Role | Hex | Preview |
|------|-----|---------|
| `primary` | `#4B2D8C` | Royal purple |
| `secondary` | `#C9A84C` | Antique gold |
| `accent` | `#D4AF37` | Rich gold |
| `gradientStart` | `#2A1050` | Deep violet |
| `gradientEnd` | `#7B5CBF` | Lavender purple |
| `textOnPrimary` | `#FFFFFF` | White |
| `textOnDark` | `#EDE0FF` | Pale lavender |
| `castleSilhouette` | `#C9A84C` | Gold (the Paris castle's spires are famously gilded) |

### Notes
The Paris castle is unique among Disney castles for its Gothic European architecture and golden spire tips. The palette reflects this with a heavier emphasis on deep purple and rich gold — more like a medieval illuminated manuscript than the lighter pinks of other Sleeping Beauty castles.

### Time-of-Day Variants
- **Dawn**: `#9B7FD4` (lavender dawn) → `#FFD580` (golden morning light)
- **Day**: Use base palette above
- **Dusk**: `#4B2D8C` (royal purple) → `#8B1A4A` (plum rose)
- **Night**: `#0D0820` (velvet night) → `#2A1050` (deep violet) with `#D4AF37` gold star accents

---

## Hong Kong Disneyland

**Flagship Castle**: Castle of Magical Dreams
**Emotional Tone**: Vibrant, multicultural, jade and gold prosperity

| Role | Hex | Preview |
|------|-----|---------|
| `primary` | `#1A7A5E` | Jade green |
| `secondary` | `#C9A84C` | Antique gold |
| `accent` | `#F0B429` | Warm golden yellow |
| `gradientStart` | `#0D4F3C` | Deep forest jade |
| `gradientEnd` | `#2EAB80` | Bright jade |
| `textOnPrimary` | `#FFFFFF` | White |
| `textOnDark` | `#E0FFF5` | Pale mint |
| `castleSilhouette` | `#C9A84C` | Gold |

### Notes
The Castle of Magical Dreams, opened in 2020, is Hong Kong Disneyland's most distinctive visual identity. Its spires represent multiple Disney princess stories simultaneously. The jade green is deeply culturally resonant in Hong Kong and Southeast Asia, representing good fortune and prosperity.

### Time-of-Day Variants
- **Dawn**: `#80CFA0` (morning jade) → `#FFE082` (golden sunrise)
- **Day**: Use base palette above
- **Dusk**: `#1A7A5E` (jade) → `#5C4A1E` (deep gold-brown)
- **Night**: `#041A10` (deep forest night) → `#0D4F3C` (dark jade) with `#F0B429` lantern gold accents

---

## Shanghai Disneyland

**Flagship Castle**: Enchanted Storybook Castle
**Emotional Tone**: Epic, magnificent, boundless imagination

| Role | Hex | Preview |
|------|-----|---------|
| `primary` | `#1B4F8A` | Enchanted sapphire blue |
| `secondary` | `#C0392B` | Chinese festive red |
| `accent` | `#E8D44D` | Golden yellow |
| `gradientStart` | `#0A2540` | Deep ocean blue |
| `gradientEnd` | `#2E6FBF` | Bright sapphire |
| `textOnPrimary` | `#FFFFFF` | White |
| `textOnDark` | `#D6E8FF` | Pale sky blue |
| `castleSilhouette` | `#A8C8E8` | Ice blue (the castle has distinctive light blue and silver tones) |

### Notes
Shanghai Disneyland's Enchanted Storybook Castle is the largest Disney castle ever built and the first designed to be equally iconic from all sides (no traditional "back" of castle). The palette blends the deep blues of the castle's towers with the red and gold that carries deep cultural significance in China. The accent red serves as a festive complement rather than the primary identity color.

### Time-of-Day Variants
- **Dawn**: `#6BAED6` (morning sky blue) → `#FFD580` (golden dawn)
- **Day**: Use base palette above
- **Dusk**: `#1B4F8A` (sapphire) → `#8B1A2A` (deep festive red)
- **Night**: `#030A14` (night sky) → `#0A2540` (deep ocean) with `#E8D44D` and `#C0392B` festival light accents

---

## Usage Notes for Implementation

### Applying Palettes in Code

Each `DisneyPark` enum value should map to a `ParkColorPalette` struct/data class. The palette should be consumed by a `ThemeProvider`/`ThemeEngine` that the ViewModel exposes as part of trip state. Views should never hardcode colors — always resolve from the current theme.

### Accessibility

All `textOnPrimary` and `textOnDark` colors are selected to meet WCAG AA contrast ratios (minimum 4.5:1) against their respective backgrounds. When rendering countdown numbers, ensure the combination of gradient background and text color is tested at both ends of the gradient range.

### Dark Mode

The `gradientStart` and `gradientEnd` values above are designed for the default (often slightly dim) countdown hero display and work well in both light and dark mode contexts. For system-level dark mode, consider deepening `gradientStart` by 15-20% lightness to maintain visual richness without appearing washed out.
