# Five Cubed Moments — UI Design Exploration

**Goal:** Move from system-default styling to a **modern, cozy, minimalist** look.

---

## 3 Design Concepts

### Concept 1: "Warm Paper" — Cream & Earth Tones
**Mood:** Morning coffee, notebook, soft sunlight

A paper-like, tactile feel with warm off-whites, soft browns, and gentle shadows. Typography feels handwritten or editorial. Inputs have subtle borders, rounded corners, and a lot of breathing room.

| Element | Approach |
|---------|----------|
| **Background** | Cream (#F8F4EF), warm paper (#F5EDE4) |
| **Text** | Charcoal (#2C2C2C), muted brown (#5C5346) for secondary |
| **Accent** | Terracotta (#C77B5B) or sage green (#8B9A7D) |
| **Inputs** | Rounded (16–20pt), light border, soft focus state |
| **Cards/Sections** | Minimal dividers, generous padding, subtle elevation |
| **Typography** | Serif for headers (e.g. Georgia, or a premium like Playfair), sans for body |

**Similar apps for reference:**
- [Cozy Reflections](https://apps.apple.com/us/app/cozy-reflections/id6752515986) — Calming, distraction-free, beautiful themes
- [Dot Log: Minimalist Journal](https://apps.apple.com/us/app/dot-log-minimalist-journal/id6756923564) — Dark mode default, smooth interactions
- [Cream iOS UI Kit (Dribbble)](https://dribbble.com/yungfrish/projects/1037719-Cream-iOS-UI-Kit) — Cream/beige palette, asymmetric layouts

---

### Concept 2: "Quiet Night" — Soft Dark Mode
**Mood:** Evening journaling, low light, focus

A dark-but-warm interface that’s easy on the eyes. Deep navy or charcoal backgrounds with soft amber/gold accents and muted secondary text. Feels intentional and calming.

| Element | Approach |
|---------|----------|
| **Background** | Warm dark (#1C1C1E), soft navy (#1E2433) |
| **Text** | Off-white (#F5F0E8), muted (#9A9A9A) |
| **Accent** | Soft amber (#E8B86D), muted gold (#C9A962) |
| **Inputs** | Dark fill, thin border, glowing focus |
| **Sections** | Very subtle separators, grouped by spacing only |
| **Typography** | Clean sans (SF Pro), slightly larger for readability |

**Similar apps for reference:**
- [Tesseract - Emotional Journal](https://apps.apple.com/us/app/tesseract-emotional-journal/id6599853294) — "Stunning UI," subtle gloom, efficient composition
- [Dot Log](https://apps.apple.com/us/app/dot-log-minimalist-journal/id6756923564) — Dark mode default, haptic feedback

---

### Concept 3: "Breath" — Ultra Minimal Light
**Mood:** Meditation app, clear mind, lots of white space

Maximum simplicity. Mostly white or very light gray, one accent color used sparingly, generous margins, large touch targets. Form controls become minimal lines or underlines. No heavy borders or blocks.

| Element | Approach |
|---------|----------|
| **Background** | Pure white (#FFFFFF) or subtle gray (#FAFAFA) |
| **Text** | Near-black (#1A1A1A), light gray (#8E8E93) |
| **Accent** | Single accent — soft blue (#6B9BD1) or sage (#7A9B76) |
| **Inputs** | Underline-only or ghost-style, minimal chrome |
| **Sections** | Spacing and typography hierarchy only, no dividers |
| **Typography** | SF Pro or similar system font, clear hierarchy |

**Similar apps for reference:**
- [Daily Spiral](https://dailyspiral.app/) — One prompt, one page, ultra-minimal
- [Depthful: Mindful Journal](https://apps.apple.com/us/app/depthful-mindful-journal/id6479280808) — Clean, distraction-free writing

---

## Quick Comparison

| | Warm Paper | Quiet Night | Breath |
|---|------------|-------------|--------|
| **Vibe** | Cozy, tactile | Calm, evening | Clean, meditative |
| **Dominant** | Creams, browns | Dark + amber | White, sparse |
| **Best for** | Morning/anytime | Night use | Quick, focused use |
| **Complexity** | Medium | Medium | Lowest |

---

## How to Visualize

1. **HTML mockups** — Open the following in a browser:
   - `docs/mockups/concept-1-warm-paper.html`
   - `docs/mockups/concept-2-quiet-night.html`
   - `docs/mockups/concept-3-breath.html`

2. **Reference apps** — Install or browse App Store screenshots for the apps listed above.

3. **Next step** — Choose a concept (or mix), and we can implement it in SwiftUI.

---

## Non-List Input for the "5s"

To avoid the rigid list feel for Gratitudes / Needs / People To Pray For, see **[Alternative Input Patterns](ALTERNATIVE_INPUT_PATTERNS.md)** — Chip Flow, Journal Prose, Sequential Reveal, and Card Grid. Mockups: `docs/mockups/concept-1-warm-paper-chips.html`, `-prose.html`, `-sequential.html`.
