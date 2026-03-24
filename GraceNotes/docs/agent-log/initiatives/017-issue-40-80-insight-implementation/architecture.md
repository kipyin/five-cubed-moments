---
initiative_id: 017-issue-40-80-insight-implementation
role: Architect
status: in_progress
updated_at: 2026-03-24
related_issue: 40
related_pr: none
---

# Architecture

## Inputs Reviewed

- **Active UI spec:** [`design.md`](design.md) (Designer — three inset boxes, spacing, typography defaults, thin-week behavior)
- **Archived planning:** [`016-issue-80-insight-direction`](../archive/016-issue-80-insight-direction/) — `brief.md`, `architecture.md`, `design.md`
- This folder: `brief.md`
- `GraceNotes/docs/03-review-insight-quality-contract.md`
- `GraceNotes/docs/04-review-insight-examples.md`
- `GraceNotes/GraceNotes/Features/Journal/Views/ReviewScreen.swift` (current `ReviewSummaryCard`)
- `GraceNotes/GraceNotes/Localizable.xcstrings` (section titles: `This week`, `A thread`, `A next step`)

## Goals

1. **#40 (UI, first)** — Ship the **one outer card** with **three inset boxed panels** (scan-first IA) for **Observation → Thinking → Action**, with **Marketing-final** strings (`This week` / `A thread` / `A next step` and zh-Hans parity), **source shown once** at the top of the outer card (above the three boxes), per **[`design.md`](design.md)** (including soft inset treatment and hard caps).
2. **#80 (engine, second)** — Align generation, sanitizer, fixtures, and tests with the same three-beat semantics **without expanding the v1 JSON contract**: `narrativeSummary` carries **Thinking**; factual window content in **Observation** (`recurring*`, factual **`resurfacingMessage`**); **`continuityPrompt`** as **Action**. Reduce generic feel and duplication so **Thinking is ≥ one conceptual step beyond Observation** when evidence allows.
3. **Contract continuity** — Treat **`03-review-insight-quality-contract.md`** as authoritative for keys, gates, and thin-evidence behavior unless Strategist explicitly revises the contract; **v1 stays on the current payload shape** (no new required keys for Thinking/Observation split).

## Non-Goals

- **No v1 contract expansion** — Adding a dedicated **Thinking** (or split **Observation**) string field is **out of scope** for this initiative unless Strategist + contract doc explicitly escalate; that remains a labeled **v2+** path from archived **016**.
- **No widening** of the seven-day review window or silent changes to quality-gate philosophy.
- **No per-section source label** in v1 (future **#83**).
- **No prescriptive “homework”** Action pattern or multi-prompt Action surfaces.
- **Explicit anomaly-style Observation copy** in v1 only if thresholds and tests are cheap; otherwise **defer** per archived brief (recurring + resurfacing first).
- **No loud inset chrome** — Inset panels must stay **low contrast** (soft stroke and/or subtle fill per **`design.md`**), not high-contrast “dashboard tiles.”

## Technical Scope

### Phase A — GitHub **#40** (presentation)

- Refactor **`ReviewSummaryCard`** (and related Review views) so a **single weekly insight** matches **[`design.md`](design.md)**:
  - **Outer container:** existing **`reviewPaper`**-style card (corner radius **~16**, outer padding **~16**).
  - **Meta band** (inside outer card, **above** boxes): **Source** row + chip, then **date range** in **`warmPaperMeta`**; **~8pt** between source and range, **~12–16pt** below range before box 1.
  - **Three inset panels:** separate rounded rects (**radius ~10–12**), **~10–12pt** vertical gap between panels; **1pt** low-opacity stroke (same token family as outer border) **and/or** half-step fill (e.g. **`reviewBackground`** on **`reviewPaper`**) — **Designer** picks calmest combo on device (**`design.md`** Open Questions).
  - **Inner padding** per panel **~12–14pt** (slightly less than outer **16** so nesting reads clearly).
  - **Per panel:** title **`warmPaperBody.weight(.semibold)`** + **~8pt** + body; **all three inset paragraph bodies** share **`warmPaperBody`** + **`reviewTextPrimary`** and the same comfortable `lineSpacing` (recurring subheads/lists inside box 1 stay **`warmPaperMeta`**); recurring blocks **only inside box 1**, indented **~4pt** or **`VStack` spacing ~6**; **Action** stays short (1–2 lines), no **“Continue with”** subheading.
  - **No repeated thin copy across panels:** when raw field resolution would show the **same normalized string** in **This week** and **A thread**, or when **A next step** would duplicate **This week** or **A thread**, **`ReviewSummaryCard`** substitutes **distinct** localized thin-week lines (**`design.md`** thin mock / Marketing strings)—**Action** no longer falls back to the full **Thinking** chain (continuity + weekly action only, then distinct placeholder).
- **Title deduplication:** Remove or avoid a large **`Playfair` / `warmPaperHeader` “This Week”** above the three-box stack if it **duplicates** the localized section **“This week”** — first meaningful heading inside the weekly unit should be **box 1** per **`design.md`**.
- **Map existing fields** into boxes: Observation = factual **`resurfacingMessage`** + recurring rows; Thinking = **`narrativeSummary`** when shown (existing gating such as `shouldShowNarrativeSummary`); Action = **`continuityPrompt`**.
- **Thin week:** **All three boxes and titles** remain; **omit empty recurring lists** (no filler bullets) per **`design.md`**.
- Enforce **hard caps** from **`design.md`** (Observation ≤4 lines / ~360 chars, Thinking ≤5 / ~480, Action 1–2 lines, prefer single question) with ellipsis / clipping; allow vertical growth at large Dynamic Type without horizontal scroll where possible.
- **Accessibility:** each inset **section title** is a header (e.g. `.accessibilityAddTraits(.isHeader)`); focus order meta → box 1 → box 2 → box 3 (with recurring lists inside box 1 before box 2); **Source** announced once.
- **`weeklyInsights` vs flat payload:** until **#80** unifies engine output, **#40** keeps **three inset boxes** and consistent section chrome; **tolerate partial duplication** only where existing gates require it—goal is **stable IA**, not final copy perfection. Prefer **clamping box 1** height if long **`weeklyInsights`** content pushes **A thread** unreasonably far down on small devices.

### Phase B — GitHub **#80** (engine)

- **Prompt and sanitizer** work so model/deterministic output **fills the three beats** without contradicting the contract: Observation = **facts**; Thinking = **relationships** grounded in Observation; Action = **one** invitational continuity prompt (often informed by Thinking; **decoupled** allowed on failure per archived **016**).
- **Light week:** Observation collapses to **one truthful line**; Thinking/Action stay shorter; **all three section titles** still justified where the UI shows **three boxes** (headers never dropped).
- **Quality mechanisms:** smallest effective combo of **forbidden phrase / pattern list** and/or **second validation pass**—pick in implementation and cover with tests.
- **Fixtures and tests** updated so examples match the new tone bar and field roles; audit **`04-review-insight-examples.md`** alignment as needed.
- **Deterministic / multi-insight paths:** collapse or map multi-item **`weeklyInsights`** output into Observation/Thinking bodies per archived brief + **#40** layout (exact merge strategy is part of **#80** close criteria once **#40** structure is fixed).

## Affected Areas

- **UI:** `ReviewScreen.swift`, `ReviewSummaryCard`, related Review components (`ReviewWeeklyInsightsSection`, theme rows, loading states).
- **Strings:** `Localizable.xcstrings` (section keys already shipped; avoid competing **“This Week”** chrome vs section **“This week”** per **design.md**).
- **Engine / services:** insight generation, sanitization, JSON decoding, any `weeklyInsights` assembly; test fixtures under **`GraceNotesTests`** (and contract-related docs only if **#80** explicitly updates them—otherwise code + tests only).

## Risks

- **Duplication** between **`resurfacingMessage`** and **`narrativeSummary`** until **#80** tightens prompts—**#40** should not hide boxes; **#80** must **push facts down** to Observation and reserve Thinking for cross-signal synthesis (archived **016** angle A).
- **`weeklyInsights` branch** may diverge from flat path; inconsistent chrome or double headings if merge strategy is vague—mitigate in **#40** with minimal structural unification, finish in **#80**.
- **Thin evidence** (&lt; 3 meaningful entries, deterministic path): all **three boxes** with **softer, shorter** copy; engine and UI must agree on **non-empty fallbacks** for **A thread** where **`design.md`** requires a line (deterministic copy from engine vs on-device placeholder — see Open Questions).
- **Inset visual weight** — Too-strong borders on three panels feel busy and conflict with **Impeccable** calm; mitigate with **low-contrast** stroke/fill (**`design.md`**).
- **Dynamic Type + three boxes** — Taller stack and more scroll on small phones; caps and **box 1 clamp** (if needed) limit regression.
- **Anomaly language** without thresholds risks false alarms or brittle tests—default **defer** in v1.
- **Localization:** ensure **en** / **zh-Hans** labels do not **over-promise** clinical depth or precision (Marketing already finalized keys; **#80** copy must match).

## Sequencing

1. **Land #40** (UI + three inset boxes + caps + a11y + stable IA on current payloads).
2. **Then #80** (prompts, sanitizer, fixtures, tests, deterministic/weeklyInsights unification) so copy and structure match without **v1** contract key changes.
3. **Translator / Marketing** on any **new** user-visible strings introduced by **#80** (if any); section titles already shipped—avoid churn unless copy changes force it.

## Close Criteria (testable)

### #40 (UI) — done when

- [x] Weekly insight is **one outer card** with **three visible inset boxes** in order: **This week** → **A thread** → **A next step**, using the shipped localization keys; each beat is its own **rounded inset panel** (approx. **radius ~10–12**, **~10–12pt** gap between panels) per **`design.md`**. *(Implemented in `ReviewSummaryCard.swift`.)*
- [x] **Inset treatment** is **soft** (low-opacity stroke and/or subtle fill — not loud tiles); matches **Designer** choice from **`design.md`** Open Questions. *(Fill + stroke on `ReviewInsightInsetPanel`.)*
- [x] **Source** appears **once** at the **top** of the outer card, **above** the three boxes; **~8pt** / **~12–16pt** meta spacing bands respected relative to **`design.md`** (QA may verify visually / Builder documents constants).
- [x] **No competing top title:** large **`Playfair` “This Week”** (or equivalent) is **not** duplicated against the **“This week”** section title inside box 1 — **`design.md`** deduplication satisfied. *(No duplicate header above the card in `ReviewScreen`.)*
- [x] **Box 1** shows factual **`resurfacingMessage`** (inset **body** typography, same as boxes 2–3) and **recurring lists only inside this box** with nested indent / tight spacing per **`design.md`** (recurring rows stay **meta**); **Box 2** = **`narrativeSummary`** when gated on; **Box 3** = **`continuityPrompt`** (or distinct thin-week substitute when it would duplicate box 1 or 2) without **“Continue with”** subheading.
- [x] **Thin week:** all **three boxes** remain; **empty recurring lists omitted** (no filler) per **`design.md`**.
- [x] **Hard caps** from **`design.md`** are enforced in UI (line/char clipping as specified).
- [ ] **VoiceOver / headers:** each **section title inside an inset box** is a header; reading order: meta → box 1 (including recurring) → box 2 → box 3. *(`.accessibilityAddTraits(.isHeader)` on titles — **confirm on Simulator/device**.)*
- [x] **Light week / empty narrative:** box titles remain; bodies match **`design.md`** fallback expectations (placeholder or engine-provided short line — coordinate with **#80**). *(Thin-week localized substitutes in `dedupedPanelBodies`.)*

### #80 (engine) — done when

- [x] Generated (and deterministic) output **roles** match **Observation / Thinking / Action** under the **existing JSON keys**; **Thinking** is not merely a restatement of Observation when multiple signals exist. *(Deterministic: `WeeklyInsightCandidateBuilder.narrativeSummary`; cloud: prompt + `CloudReviewInsightsSanitizer` parrot repair.)*
- [x] **Sanitizer / gates** reject or repair **forbidden** tone patterns agreed for this release; tests or fixtures document expected behavior. *(Existing generic-phrase gate + new duplicate narrative/resurfacing repair covered by unit tests.)*
- [x] **Fixture suite** (and any contract conformance tests) **pass** and reflect the archived **016** intent; **light week** and **thin entry** paths produce copy that fits **#40** layout without fake density. *(Run `GraceNotesTests` on macOS; `CloudReviewInsightsLiveAPITests` remains optional network smoke.)*
- [x] **`weeklyInsights` vs single-insight presentation** resolved per **Technical Scope** (no conflicting duplicate surfaces; deterministic output maps into the **three inset boxes** / field roles). *(Cloud: one `weeklyInsights` row mirrors top-level fields; deterministic: up to two candidates feed flat `resurfacingMessage` / `narrativeSummary` / `continuityPrompt`.)*
- [x] **Escalation:** If implementation discovers a **hard** need for a new JSON field, **stop** and record in **`pushback.md`** + Strategist; **do not** silently extend the contract. *(No new keys in this pass.)*

## Decision

**v1 implementation** follows archived **016**: **serial delivery #40 then #80**; **no new insight JSON keys** unless explicitly escalated. **#40** implements **[`design.md`](design.md)** as the **authoritative layout spec**: one outer **`reviewPaper`** card, **meta band** (source + date), then **three soft inset boxes** (Observation / Thinking / Action) with the **spacing, radii, typography defaults, title deduplication, and thin-week** rules documented there, plus **hard caps**. **#80** aligns prompts, sanitization, and tests with the same semantic mapping and contract gates, including merge/unification of **`weeklyInsights`** with the flat path. **Anomaly-heavy Observation copy** stays **deferred** in v1 unless thresholds and tests are straightforward.

## Rationale

- UI-first (**#40**) locks **information architecture** and prevents **#80** from optimizing text against a moving surface.
- Keeping the **current payload** avoids a coordinated contract migration while still allowing large **perceptual** improvement via layout + copy discipline.
- Archived **016** already resolved **field mapping**, **thin week** behavior, and **Marketing** labels; this file turns those into **sequenced, testable** engineering work.

## Open Questions

- **Inset panel style on device** — **stroke-only** vs **fill shift only** vs **both** (**`design.md`**); **Designer** picks calmest; Builder encodes tokens.
- **Exact `weeklyInsights` vs flat merge** — Resolved in **#40** PR at minimum viable level; **#80** owns final output shape. Document the chosen behavior in code comments or tests.
- **Thinking fallback line** when narrative is empty—**fully on-device string** vs **engine-provided** deterministic line: pick during **#40**/**#80** handoff so **box 2** is never blank.
- **Action copy punctuation** (leading arrow / em dash): **Marketing** per **`design.md`**; default plain question.

## Next Owner

**Release Manager** — Land **#40/#80** via PR to **`main`** (coordinate version lane with **[`018-release-0-5-2-patch`](../018-release-0-5-2-patch/)** if packaging together). **Human** still runs **`testing.md`** VoiceOver / Dynamic Type checks before App Store submission.
