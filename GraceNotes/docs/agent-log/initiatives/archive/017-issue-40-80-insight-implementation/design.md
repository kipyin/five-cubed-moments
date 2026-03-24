---
initiative_id: 017-issue-40-80-insight-implementation
role: Designer
status: completed
updated_at: 2026-03-25
related_issue: 40
related_pr: none
---

# Design: Weekly insight layout (refined)

## Inputs Reviewed

- [Archived `016` design spec](../016-issue-80-insight-direction/design.md) (canonical mapping, caps, localization keys)
- [017 `architecture.md`](architecture.md)
- `.impeccable.md` (calm hierarchy, warm paper, low cognitive load)
- Current implementation: `ReviewScreen.swift` — `ReviewSummaryCard`

## Decision

**Locked (product):** Use **three inset boxes** after the meta band so **Observation → Thinking → Action** scan instantly; **one** outer weekly card still frames the whole insight.

**Refined layout intent**

1. **One weekly unit, three inset boxes** — Keep **one** outer weekly insight container (existing `reviewPaper` card with outer padding and corner radius **~16**). Inside it, after the **meta band**, present **Observation**, **Thinking**, and **Action** as **three separate inset panels**—each its own rounded rect (**corner radius ~10–12**), **1pt** stroke at low opacity (same token family as the outer card border) and/or a **half-step** background shift (e.g. `reviewBackground` inside `reviewPaper`) so panels read as **quiet layers**, not three KPI tiles. **~10–12pt** vertical gap **between** panels.
2. **One card, no competing top titles** — Prefer **no** large `Playfair` “This Week” header *above* the three-box model. Screen chrome may stay minimal. The first **meaningful** heading inside the weekly unit is **`This week`** (box 1 title). Avoid duplicating “this week” at two typographic levels.
3. **Meta band (unboxed or flush)** — **Source** + chip; **date range** below in **`warmPaperMeta`**. This band sits **above** the three boxes (still inside the outer card). Tight **~8pt** between source and range; **~12–16pt** below range before **box 1**.
4. **Per-panel rhythm** — Inside each box: **section title (semibold body)** → **8pt** → **body**. Padding **~12–14pt** inside each inset panel (slightly less than outer card’s **16** so nesting reads clearly).
5. **Observation (box 1 — This week)** — **Resurfacing / factual paragraph first** using the **same** inset **body** style as boxes 2–3 (**`warmPaperBody`** + **`reviewTextPrimary`**, comfortable shared `lineSpacing`) so the three panels read as one typographic system. Then **12pt** gap, then **recurring blocks** inside the **same** box—**recurring subheads and list rows** stay **`warmPaperMeta`** (muted); indent list content **~4pt** or tighter `VStack` spacing (6) so gratitudes/needs/people stay **children** of this week, not separate cards.
6. **Thinking (box 2 — A thread)** — Same **body** stack as box 1 (**`warmPaperBody`** + primary color). Only this panel’s body should run long (higher line cap); keep **full width** inside the inset (respect inner horizontal padding).
7. **Action (box 3 — A next step)** — **No** “Continue with” subheading. One **short** block (1–2 lines), same **body** typography as boxes 1–2. Optional leading punctuation in copy **only if** Marketing agrees.
8. **Thin payload, distinct beats** — When engine output **collapses** the same line into **Observation** and **Thinking** (or **Action** duplicates another panel), the **UI substitutes** the **thin-week** distinct lines from the ASCII mock below (localized) so users never see **identical** placeholder copy in two sections.

**Hard caps** — Unchanged from **016** (`This week` ≤4 lines / ~360 chars, `A thread` ≤5 / ~480, `A next step` 1–2 lines); verify at **large Dynamic Type** on device.

## ASCII mock — rich week

Outer weekly card; **three inset boxes** for the beats. (ASCII uses nested corners; Builder: one `VStack` of three styled containers.)

```
  Review
  ─────

  ╭────────────────────────────────────────────────────────╮
  │  Source                               [  AI  ]         │
  │  Mar 10–16                                             │
  │                                                        │
  │    ╭──────────────────────────────────────────────╮   │
  │    │  This week                                   │   │
  │    │  You mentioned rest four times; sleep       │   │
  │    │  showed up less often than the week before. │   │
  │    │                                              │   │
  │    │    Recurring Gratitudes                      │   │
  │    │      · quiet mornings (3)                    │   │
  │    │      · coffee with a friend (2)            │   │
  │    │    Recurring Needs                           │   │
  │    │      · …                                     │   │
  │    │    People in Mind                            │   │
  │    │      · …                                     │   │
  │    ╰──────────────────────────────────────────────╯   │
  │                                                        │
  │    ╭──────────────────────────────────────────────╮   │
  │    │  A thread                                    │   │
  │    │  Rest and family often appeared together    │   │
  │    │  this week—like you were naming what        │   │
  │    │  steadied you.                              │   │
  │    ╰──────────────────────────────────────────────╯   │
  │                                                        │
  │    ╭──────────────────────────────────────────────╮   │
  │    │  A next step                                 │   │
  │    │  What’s one small thing from this week      │   │
  │    │  you’re grateful showed up?                 │   │
  │    ╰──────────────────────────────────────────────╯   │
  │                                                        │
  ╰────────────────────────────────────────────────────────╯
```

## ASCII mock — thin week

Same **three boxes** and titles; shorter bodies; omit empty recurring lists (no filler).

```
  ╭────────────────────────────────────────────────────────╮
  │  Source                            [ On-device ]     │
  │  Mar 10–16                                             │
  │                                                        │
  │    ╭──────────────────────────────────────────────╮   │
  │    │  This week                                   │   │
  │    │  A quieter week in your journal—still room  │   │
  │    │  to notice what mattered.                   │   │
  │    ╰──────────────────────────────────────────────╯   │
  │                                                        │
  │    ╭──────────────────────────────────────────────╮   │
  │    │  A thread                                    │   │
  │    │  When you’re ready, a few lines can still   │   │
  │    │  hold a lot.                                │   │
  │    ╰──────────────────────────────────────────────╯   │
  │                                                        │
  │    ╭──────────────────────────────────────────────╮   │
  │    │  A next step                                 │   │
  │    │  What’s one thing you’re glad happened,     │   │
  │    │  even if small?                             │   │
  │    ╰──────────────────────────────────────────────╯   │
  │                                                        │
  ╰────────────────────────────────────────────────────────╯
```

## Rationale

- **016** locked IA and mapping; **three inset panels** make the **Observation → Thinking → Action** beats scannable at a glance without turning the screen into unrelated widgets—outer card still reads as **one weekly insight**.
- Recurring lists stay **inside box 1** so users see **facts + patterns** as one unit before the synthesis and the nudge.
- Inset stroke / fill should stay **soft** (low contrast) to match **Impeccable**: calm, not dashboard-noisy.

## Risks

- **Three borders** can feel busy if contrast is too high—prefer **lighter stroke** or **fill-only** inset over a strong outline.
- **Dynamic Type** + three boxes increases vertical scroll; cap copy per **016** and test on **small phone + XXXL** type.
- If **`weeklyInsights`** adds long content in **Observation**, clamp **box 1** height first so **A thread** remains reachable without excessive scroll.

## Open Questions

- **Inset style A/B** on device: **stroke-only** vs **fill shift only** vs **both**—pick the calmest that still separates the three beats.
- **Arrow / em dash** in Action copy: **Marketing** decides; default plain question.

## Next Owner

**Builder** — Implement **#40** per [architecture.md](architecture.md); use this doc for **three inset panels**, **spacing hierarchy**, and **title deduplication** against current `ReviewSummaryCard`.
