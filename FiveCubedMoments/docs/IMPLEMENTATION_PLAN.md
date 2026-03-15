# Five Cubed Moments — Design Spec Implementation Plan

This document outlines the implementation plan for the UI design specification in `DESIGN_SPEC.md`. The final design targets a **Warm Paper** theme with **Sequential input** and **Natural Language summarization** for Gratitudes, Needs, and People To Pray For sections.

---

## Executive Summary

| Area | Current State | Target State |
|------|---------------|--------------|
| **Theme** | System defaults (Theme.swift has only `primaryColor`) | Warm Paper palette, custom typography |
| **Input UX** | 5 separate TextFields per section | Single input, Enter → summarize → chip, repeat |
| **Data** | Plain `[String]` arrays | Full sentence stored; chip shows summarized label |
| **Summarization** | None | NL framework (primary) + first-N words fallback |

---

## Phase 1: Warm Paper Theme

### 1.1 Color Palette

Add to `DesignSystem/Theme.swift` (or new `DesignSystem/WarmPaperTheme.swift`):

| Token | Hex | Usage |
|-------|-----|-------|
| `background` | `#F8F4EF` | Main app background |
| `paper` | `#F5EDE4` | Card/device surfaces |
| `textPrimary` | `#2C2C2C` | Headers, primary text |
| `textMuted` | `#5C5346` | Secondary text, placeholders |
| `accent` | `#C77B5B` | Buttons, focus rings, active elements |
| `complete` | `#8B9A7D` | Completed state, chip backgrounds |
| `border` | `#E5DDD4` | Input borders, dividers |

### 1.2 Typography

- **Headers**: Playfair Display (serif) — Section titles, "Today's 5³"
- **Body**: Source Serif — Body text, inputs

**Implementation:**

1. Add font files to the project:
   - Playfair Display (e.g., from Google Fonts)
   - Source Serif 4
2. Register fonts in Info.plist under `UIAppFonts`
3. Extend `Theme.swift` with `Font.warmPaperHeader`, `Font.warmPaperBody`
4. Apply `preferredColorScheme(.light)` and background colors at app root

### 1.3 Input Styling

- Rounded corners: 14–16pt
- Light border (`#E5DDD4`)
- Soft focus state: accent border + subtle box-shadow / focus ring

---

## Phase 2: Data Model Changes

### 2.1 From Plain Strings to Rich Items

**Current:** `JournalEntry` stores `gratitudes: [String]`, `needs: [String]`, `people: [String]`.

**Target:** Store full sentence and optional chip label.

**Options:**

| Option | Pros | Cons |
|--------|------|------|
| **A. New model type** | Clean separation | Migration from existing `[String]` entries |
| **B. Keep `[String]`** | No migration | Chip label recomputed on load; no persisted distinction between NL vs first-N |

**Recommendation:** Option A — Introduce a Codable/SwiftData-compatible struct:

```swift
struct JournalItem: Codable {
    var fullText: String      // Always the full sentence
    var chipLabel: String?     // NL/extracted or first-N; nil = recompute
}
```

- `JournalEntry.gratitudes` → `[JournalItem]` (or persisted as JSON/encoded)
- Migration: Map existing `[String]` to `[JournalItem(fullText: s, chipLabel: nil)]` on first load

**Alternative (simpler):** Keep `[String]` as full text; recompute chip labels on demand. Only introduce `JournalItem` if we need to persist NL vs first-N distinction for UI (e.g., whether to show fade). For v1, recomputing is acceptable.

---

## Phase 3: Summarization Service

### 3.1 Abstraction

Create `Summarizer` protocol:

```swift
protocol Summarizer {
    func summarize(_ sentence: String) -> String
}
```

- Enables future cloud API swap (per spec section 3).
- Inject into ViewModel for testability.

### 3.2 Natural Language Implementation

Create `NaturalLanguageSummarizer` using:

- `NLTagger` with `.name` or `.lexicalClass` to extract nouns/keywords
- `NLTokenizer` to split into words
- Strategy: Extract nouns > 2 chars; if none, use first meaningful phrase (skip articles)

**File:** `FiveCubedMoments/Services/Summarization/NaturalLanguageSummarizer.swift`

### 3.3 First-N Fallback

When NL returns empty or trivial result:

- Use first N words (e.g., N = 4–5)
- Mark result as "truncated" so UI can apply fade styling.

```swift
struct SummarizationResult {
    let label: String
    let isTruncated: Bool  // true = use fade on chip
}
```

### 3.4 Future: Cloud API Placeholder

Add `CloudLLMSummarizer` stub that conforms to `Summarizer`; wire via config or feature flag when ready.

---

## Phase 4: Sequential Input UX

### 4.1 Flow

1. Single `TextField` per section (Gratitudes, Needs, People)
2. User types full sentence → presses **Return** (or "Add" button)
3. Summarizer runs → chip created; full text stored
4. Input clears; next slot ready (e.g., "Gratitude 2")
5. Repeat until 5 items

### 4.2 UI Components

| Component | Responsibility |
|-----------|-----------------|
| `SequentialSectionView` | Wraps chips + single input + progress (e.g., "4 of 5") |
| `ChipView` | Displays label; truncated variant with right-edge gradient mask |
| `SequentialInputField` | TextField with Warm Paper styling, `.onSubmit` trigger |

### 4.3 Progress Indicator

Display "X of 5" below input for each section.

### 4.4 Sections Unchanged

- **Bible Notes** and **Reflections** remain `TextEditor` (multi-line); apply same Warm Paper input styling.

---

## Phase 5: Chip Display

### 5.1 Normal Chip (NL or Short Label)

- Short label (1–3 words) shown in full
- Style: Rounded pill (e.g., 16pt radius), `complete`-tinted background (`rgba(139,154,125,0.2)`)

### 5.2 Truncated Chip (First-N Fallback)

- First N words with **gradual fade** at right edge
- Implementation: `LinearGradient` mask or `.mask` with gradient overlay
- Max width or character limit (e.g., ~20 chars)
- Full sentence stored; tap to view/edit

### 5.3 Tap-to-Expand/Edit

- Tap chip → sheet or inline expansion showing full sentence
- Allow edit; on save, re-summarize if needed and update chip

---

## Phase 6: JournalScreen Refactor

### 6.1 Replace Form with Custom Layout

- Move from `Form` to `ScrollView` + `VStack` to control Warm Paper layout
- Match mockup: device-style container, section labels, date row with Completed badge

### 6.2 Section Structure (per mockup)

```
DATE
  [Mar 15, 2025] [Completed badge]

GRATITUDES
  [Chip] [Chip] [Chip]
  "What's one thing you're grateful for?"
  [Input field]
  4 of 5

NEEDS
  ...
```

### 6.3 Share Card

- Update `JournalShareCardView` and `JournalShareRenderer` to use Warm Paper colors and fonts
- Share card should reflect full text (not chip labels) for gratitudes/needs/people

---

## Phase 7: History & Consistency

### 7.1 HistoryScreen

- Apply Warm Paper theme (background, list row styling)
- `HistoryRow` completion indicator: use `complete` (#8B9A7D) instead of system green

### 7.2 Global Application

- Set `WindowGroup` background to cream
- Apply theme to TabView, NavigationStack
- Share button: accent color, styled per mockup

---

## Implementation Order

| Step | Task | Dependencies |
|------|------|--------------|
| 1 | Theme: colors + typography + apply globally | None |
| 2 | Summarization: protocol + NL + fallback | None |
| 3 | Data: decide JournalItem vs recompute; implement migration if needed | None |
| 4 | ChipView component (normal + truncated with fade) | Theme |
| 5 | SequentialSectionView + SequentialInputField | Theme, Summarizer, ChipView |
| 6 | JournalViewModel: sequential add flow, integrate Summarizer | Data, Summarizer |
| 7 | JournalScreen: replace Form, wire SequentialSectionView | Steps 1–6 |
| 8 | Share card + History theme updates | Theme |
| 9 | Tap chip → expand/edit | ChipView, ViewModel |

---

## File Structure (New/Modified)

```
FiveCubedMoments/
├── DesignSystem/
│   ├── Theme.swift           (expand: Warm Paper palette)
│   └── Fonts.swift           (optional: custom font extensions)
├── Features/Journal/
│   ├── Views/
│   │   ├── JournalScreen.swift           (major refactor)
│   │   ├── SequentialSectionView.swift   (new)
│   │   ├── ChipView.swift                (new)
│   │   ├── SequentialInputField.swift   (new, or inline)
│   │   └── JournalShareCardView.swift    (theme update)
│   └── ViewModels/
│       └── JournalViewModel.swift       (sequential flow, summarization)
├── Services/
│   └── Summarization/
│       ├── Summarizer.swift              (protocol)
│       ├── NaturalLanguageSummarizer.swift
│       └── FirstNWordsSummarizer.swift   (fallback)
├── Data/Models/
│   └── JournalEntry.swift                (possible JournalItem)
```

---

## Testing Considerations

| Test Type | Notes |
|-----------|-------|
| **Unit** | `NaturalLanguageSummarizer` with fixture sentences; `FirstNWordsSummarizer` edge cases |
| **ViewModel** | Add-item flow, autosave, completion logic with sequential items |
| **Snapshot/UI** | Warm Paper screens (requires macOS/Xcode) |
| **Migration** | If introducing `JournalItem`, verify existing entries load and display correctly |

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| NL extraction poor for some languages | Fallback to first-N is always available |
| SwiftData schema change | Use lightweight migration; store `[String]` as JSON if adding metadata |
| Custom font licensing | Playfair Display and Source Serif 4 are open license (OFL) |
| Sequential UX feels slower | Optional: keep "quick add" for power users (future) |

---

## References

- Design spec: `docs/DESIGN_SPEC.md`
- Mockup: `docs/mockups/design-mockup.html`
- Apple Natural Language: [NLTagger](https://developer.apple.com/documentation/naturallanguage/nltagger), [NLTokenizer](https://developer.apple.com/documentation/naturallanguage/nltokenizer)
