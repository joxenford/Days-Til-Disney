# Marketing website UI kit

Recreation of `website/index.html` — same information architecture and copy — rebuilt in the Toy Box system.

**Sections (in source order):** nav · hero + phone · proof strip · features grid · daily content · destinations · privacy/trust · extras · final CTA · footer. `site.js` mirrors `website/app.js`: nav scrolled state and `IntersectionObserver` scroll-reveal, both respecting `prefers-reduced-motion`.

**What changed from the live site, and why**

| Live site (`website/styles.css`) | Here |
|---|---|
| Fixed star field + `linear-gradient(160deg …)` page background | Flat `--bg`; one park-coloured panel per band (hero phone, live-waits card, final CTA) |
| `.glass-card` — 7% white fill, gold border, `backdrop-filter: blur(12px)` | Flat `--surface` / `--surface-raised` tiles at 22–34px radius |
| Gold gradient `.btn--primary` with glow shadow | Ink fill `.btn--primary`, no shadow |
| Nunito 400–900 | Outfit (structure) + Karla (prose) |
| Emoji as section and feature icons (🎢 ⏳ ✨ 🧳 🇺🇸 …) | Removed — no emoji in this system; feature cards lead with the title, destinations with the country name |
| `✨` glyph standing in for the logo | Plain type wordmark — there is still no logo in the source |

**Copy is taken from the live page** (hero, feature descriptions, daily-content samples, trust list, extras, CTA, footer disclaimer). Two edits: "Milestone Celebrations / Confetti and fireworks explode" became "Milestone moments" to match this system's no-particles rule, and the destinations lede drops its inline Disney disclaimer since the footer already carries it verbatim.

**Not built:** `privacy.html` (a long-form legal page — say the word and it's quick to add).
