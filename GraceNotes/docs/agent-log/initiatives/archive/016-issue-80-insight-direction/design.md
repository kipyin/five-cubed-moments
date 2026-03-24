---
initiative_id: 016-issue-80-insight-direction
role: Designer
status: in_progress
updated_at: 2026-03-25
related_issue: 80
related_pr: none
---

# Design: Weekly insight — one card, three sections

## Inputs Reviewed

- `brief.md` (Product decisions, angles A–H, v1 payload mapping)
- `architecture.md` (contract bridge, field mapping)
- [03-review-insight-quality-contract.md](../../../03-review-insight-quality-contract.md)
- Current UI: `GraceNotes/GraceNotes/Features/Journal/Views/ReviewScreen.swift` — `ReviewSummaryCard`

## Decision

- **Surface:** A single **weekly insight card** on Review (same card as today’s `ReviewSummaryCard` conceptually). **Three labeled sections** inside the card, in order: **Observation → Thinking → Action** (user-facing strings: see **Localization** below).
- **Source (`AI` / `On-device`):** Shown **once** at the **top of the card** (keep current `sourceRow` pattern: label “Source” + chip). **Not** repeated per section (v1). Future placement toggle → **#83**.
- **Hierarchy:** For each section: **section title** (`warmPaperBody.weight(.semibold)` or header role equivalent) → **body** (`warmPaperBody` / `warmPaperMeta` per content density). Week date range stays **below source** and **above** section 1, or immediately under a single card title—**Builder** may choose the smallest diff from current layout as long as scan order is: source → range → **This week** → **A thread** → **A next step** → recurring blocks **only where they belong** (see mapping).
- **Content mapping (v1, aligns with `architecture.md`):**
  - **This week (Observation):** Factual window content: `resurfacingMessage` (factual tone), optional theme chips / `ReviewThemeRow` content (`recurringGratitudes`, `recurringNeeds`, `recurringPeople`). **Light week:** collapse to **one** short truthful line in this section (no fake lists).
  - **A thread (Thinking):** `narrativeSummary` when present and non-duplicative (respect existing `shouldShowNarrativeSummary` idea). If empty or gated off, show **one** short fallback line (deterministic copy from engine) still in this section—**do not** hide the section header (brief angle D).
  - **A next step (Action):** `continuityPrompt` as the primary body; **drop** the separate “Continue with” header when the section title carries the meaning (avoids double-heading). Single prompt only.
- **Legacy `weeklyInsights` path:** Today the UI branches between multi-item `ReviewWeeklyInsightsSection` vs resurfacing + continuity. **Target:** Regardless of backend shape, **present** the three section headers consistently; **Builder** + **#80** collapse multi-insight deterministic output into the Observation/Thinking bodies per brief. Until engine work lands, **#40** may implement layout with current payloads and tolerate partial duplication if gates require—goal is stable IA.
- **Hard caps (initial spec — tune with Dynamic Type on device):**

| Section | Default size (approx.) | Large accessibility sizes |
|--------|-------------------------|----------------------------|
| **This week** body | ≤ **4** short lines or ~**360** characters, whichever clips first with ellipsis | Allow vertical growth; prefer **no** horizontal scroll; truncate with “more” only if Strategist approves later |
| **A thread** body | ≤ **5** lines or ~**480** characters | Same |
| **A next step** body | **1–2** lines; prefer **single** question | Same |

- **Motion:** No new animation required; respect **Reduce Motion**. Loading state unchanged (`ProgressView`).

## Accessibility

- Each section title: `.accessibilityAddTraits(.isHeader)` and **VoiceOver** reads title then body in order.
- **Source** row: keep existing semantics; announce **once**.
- Recurring rows: keep per-row labels; section **This week** should precede lists in focus order if lists stay inside Observation.

## Localization

Shipped in `Localizable.xcstrings` (en + zh-Hans), **Marketing-final** for this initiative:

| Key (English) | en | zh-Hans | Role |
|---------------|----|---------|------|
| `This week` | This week | 本周 | Observation section title |
| `A thread` | A thread | 发现 | Thinking section title (`en` keeps “thread”; `zh-Hans` favors plain “what surfaced”) |
| `A next step` | A next step | 下一步 | Action section title |

**Note:** Existing **screen-level** string `This Week` (title case) remains for any chrome **outside** the three-section model; **#40** should avoid two competing top headings—prefer **one** top label (either retire duplicate or map old title to first section only).

## Open Questions

- Exact **merge strategy** for `weeklyInsights` vs flat payloads until **#80** unifies—**Architect** + Builder on **#40** PR.
- Whether **recurring theme rows** move **entirely** under Observation or keep a subtle secondary list—default: **under Observation** after resurfacing line.

## Next Owner

**Superseded by [017-issue-40-80-insight-implementation](../../017-issue-40-80-insight-implementation/)** — **Architect** ingests this spec from archive **016**, then **Builder** implements in `ReviewScreen` / `ReviewSummaryCard` (**#40**, then **#80**).
