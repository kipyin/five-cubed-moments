---
initiative_id: 016-issue-80-insight-direction
role: Strategist
status: in_progress
updated_at: 2026-03-25
related_issue: 80
related_pr: none
---

# Brief: Insight direction (planning bridge for #80)

## Strategist framing (Problem → Acceptance)

### Problem

Weekly Review insights can still feel **generic** or **disconnected from today’s journal**, even with quality gates. **#80** is the right place to iterate the engine—but without a shared product story, prompt work risks optimizing copy that users still read as “could be anyone” or that **over-interprets** thin evidence.

### User Value

Users who already trust the ritual get **compound reflection**: they see **what showed up** in the last seven days (including **shift** signals when evidence supports it), **one modest read** that ties those signals together without pretending to be therapy, and **one low-pressure nudge** that could become a line in **Gratitudes / Needs / People** today—so Review feels like a bridge, not a dead end.

### Scope In

- Product vocabulary and intent for **Observation → Thinking → Action** (aligned with contract fields via `architecture.md`).
- Explicit **non-goals** (no silent contract change, no widened window without a decision, no prescriptive “homework”).
- **Guardrails** for tone, faithfulness, AI optional + deterministic baseline, one continuity move, gratitude-loop-friendly Action.
- **Open product decisions** listed for the next Strategist pass (Thinking shape, anomaly bar, Action pattern).

### Scope Out

- Implementing **#80** (prompts, sanitizer, fixtures, tests) or **#40** UI **from this initiative folder** (implementation tracks **#40** / **#80** once design + copy are ready).
- Editing `03-review-insight-quality-contract.md` or code until direction is explicitly closed or revised.

### Priority Rationale

Strategy already ranks **return on reflection** as the top gap; **#80** is the sustained engine track. **Upstream clarity** is cheap relative to another cycle of generic-feeling output or a contract-breaking UI split done by accident.

### Acceptance Intent (for this planning initiative)

Planning is **done enough** for Architect/Designer when: (1) the three beats are stable as **user-mental-model + internal language**; (2) **Open Questions** have **prototype defaults** where still needed; (3) **v1** scope is explicit (IA + payload). **Locked:** intra-insight IA, v1 = no new JSON keys, Marketing pass, **serial** delivery order (see **Product decisions** below).

## Inputs Reviewed

- GitHub **#80** — Review: deep insight engine (prompts, fixtures, contract conformance)
- `GraceNotes/docs/03-review-insight-quality-contract.md`
- `GraceNotes/docs/04-review-insight-examples.md`
- `GraceNotes/docs/07-release-roadmap.md` (split **#40** presentation vs **#80** engine)
- `GraceNotes/docs/agent-log/initiatives/archive/014-release-0-5-0-insight-quality/brief.md` (0.5.0 shipped baseline; further **#80** depth is roadmap work)

## Product decisions (Strategist lock-in)

1. **Information architecture — intra-insight**  
   The three beats are **sections inside the same weekly insight** (one surface: one card / one scroll unit with clear hierarchy). They are **not** three separate insights, tabs, or modes.

2. **v1 — presentation without contract expansion**  
   **v1** keeps the **existing payload** (`narrativeSummary`, `resurfacingMessage`, `continuityPrompt`, recurring lists). **Thinking** stays expressed through **copy mapping** (primarily `narrativeSummary`), not a new required string field. A **future v2** that adds a dedicated Thinking field is an **explicit** contract + sanitizer + test change.

3. **Marketing**  
   After **Designer** has a stable layout (section order, optional helper line), run the normal pipeline: **Translator** for natural `zh-Hans` where new strings appear, then **Marketing** for final **en** + **zh-Hans** parity on **section labels** and any short helper microcopy (see `.agents/skills/promote/SKILL.md`). Marketing should flag if a label **promises** behavior the engine cannot yet support.

4. **Delivery — serial (no parallel conflicting tracks)**  
   **Order:** (a) this brief + `architecture.md` aligned, (b) **Designer** output for one-insight / three-section layout (**#40**), (c) **Translator → Marketing** on user-visible names, (d) **Builder**: **#40** UI first so structure is real, then **#80** prompts/sanitizer/fixtures to match the layout and tone bar.

## Decision

Grace Notes should treat **Review insights** as a single calm card with **three conceptual beats** for users and for internal design:

1. **Observation** — What the last seven days *show*, including **patterns** (repeated themes, words, people) and **anomalies** (signals that used to recur and now appear less, or shifts worth naming without dramatizing).
2. **Thinking** — One **faithful, low-risk** layer of synthesis: connect observations in plain language the user could agree with from their own entries. Not therapy, not advice, not “insights” that sound clever but aren’t grounded.
3. **Action** — One **continuity** move: a prompt or question that can plausibly feed **today’s** journal—especially gratitudes—so Review does not stop at the past week.

This initiative **does not** implement **#80**. It frames direction so later engine work (prompts, sanitizer, fixtures, tests) and optional presentation work (**#40** or follow-ons) have a shared vocabulary.

**Non-goals for this framing**

- Replacing the existing JSON contract or quality gates in code without a separate, explicit decision.
- Expanding the review window beyond the **seven local days ending on the reference day** unless strategy explicitly chooses that later.
- Turning Action into tasks, prescriptions, or social obligations the app “assigns.”

## Three sections: content definition (multi-angle discussion)

**Purpose:** Before **Designer** locks layout and **Marketing** locks labels, agree **what each section is allowed to say**—from several angles so we do not confuse *information architecture* with *copy tweaks*. Internal working names: **Observation / Thinking / Action** (user-facing terms TBD: e.g. 观察 / 思考 / 行动 or calmer product labels).

Use this as a **discussion checklist**. When an angle is resolved, add a one-line **conclusion** under that angle (or in `pushback.md` if it was a deliberate deferral).

### Angle A — Epistemic kind (what type of statement is this?)

| Section | Intended claim type | Should avoid |
|---------|---------------------|--------------|
| **Observation** | **Grounded description** of the window: recurring labels, counts, simple contrasts supported by entries (and later, anomalies only if gated). | Diagnosis, character judgments, causes (“because you are…”), predictions. |
| **Thinking** | **Faithful synthesis**: one modest “this week hung together like…” that a user could accept from their own text. | Novel facts, therapy framing, moral scoring, clever abstractions with weak anchors. |
| **Action** | **Invitational prompt** (question or very short invitation + question): one possible next reflection move, not a mandate. | Homework lists, “you should,” medical/legal advice, pushing contact the user did not imply. |

**Strategist lock:** **Thinking is always grounded in Observation** and is **at least one conceptual step beyond** it (it may be more than one step when evidence supports a slightly richer link). It must not merely restate Observation in different words. If `resurfacingMessage` and `narrativeSummary` would duplicate the same fact, **push the fact down** to Observation and use Thinking for **relationship / pattern-across-facts** only.

### Angle B — User job (what should the reader walk away with?)

| Section | Job-to-be-done (draft) |
|---------|-------------------------|
| **Observation** | “I can **see** what kept showing up (and optionally what shifted) without the app telling me who I am.” |
| **Thinking** | “The app **named one relationship** between signals that feels fair—not surprising magic, not empty summary.” |
| **Action** | “I have **one clear, low-pressure way** to continue on Today (gratitude / need / person), if I want to.” |

**Clarification (replaces the old discussion prompt):** We are **not** asking whether users “skip” Thinking mentally. All three **sections stay visible** in the layout (see **D**). The real question is whether **Thinking earns its line count**: per **A**, it must add **at least one step** beyond Observation; if the model cannot, **shorten or tighten** copy rather than duplicating Observation.

### Angle C — v1 payload mapping (what content actually fills the section?)

Per `architecture.md` (no new keys in v1):

| Section | Primary sources (v1) | Typical UI content |
|---------|----------------------|-------------------|
| **Observation** | `recurringGratitudes`, `recurringNeeds`, `recurringPeople`, factual **`resurfacingMessage`** | Theme chips / short bullets / one resurfacing line—**Designer** decides visual pattern. |
| **Thinking** | **`narrativeSummary`** (merged role) | One short paragraph or two tight lines—must stay scannable as **one** section. |
| **Action** | **`continuityPrompt`** | Single question (prototype default) or invitation + question if Marketing agrees. |

**Strategist lock:** When the week is **light** (few recurring signals, sparse lists), **Observation collapses** to a **single “light week” line** (still truthful—no filler lists). **Thinking** and **Action** still follow **A** and **F**; they do not invent density.

### Angle D — Evidence bar (when is this section “allowed” to be rich vs minimal?)

| Section | Rich when… | Thin / low-entry when… |
|---------|------------|-------------------------|
| **Observation** | Enough meaningful entries to surface recurring labels or clear resurfacing. | **One** short “light week” line (see **C**); no fake density. |
| **Thinking** | Multiple signals to connect without forcing. | **Shorter** synthesis; still **one step beyond** Observation per **A**—**Architect** + **#80** define short templates. |
| **Action** | Always at most **one** primary prompt; must not imply plans the week did not support. | Same rule; wording stays **easy to decline** mentally. |

**Strategist lock:** For **&lt; 3 meaningful entries** (deterministic path) and other thin weeks, **all three section headers still appear**, each with **softer, shorter** copy. Do **not** hide a section or merge the IA into two blocks.

### Angle E — Tone, safety, and validation

Cross-cutting rules from `04-review-insight-examples.md` (connector persona: grounded, non-clinical, non-prescriptive) apply to **all** sections; weight by risk:

- **Observation** — highest risk of sounding **judgmental** when naming drops/absences; use neutral framing (“showed up less often” not “you failed to…”).
- **Thinking** — highest risk of **overreach**; prefer **tentative bundling** (“this week often paired X with Y”) over **causal** claims.
- **Action** — highest risk of **prescription**; prefer **question form** or optional “you might…” framing.

**Strategist lock:** **#80** may use **either or both**: (1) a maintained **forbidden phrase / pattern list** (and sanitizer rules), and/or (2) a **second pass** (e.g. model or rule-based check) that scores **validity / safety** before showing output. Pick the smallest combo that catches real failure modes without latency or cost blowups—**Architect** decides in implementation.

### Angle F — Roles across facts, relationships, and next step

| Section | Role |
|---------|------|
| **Observation** | **Facts only** for the window: what recurred, counts, simple contrasts grounded in entries (and gated anomalies later). |
| **Thinking** | **Relationships** across those facts (within or across Gratitude / Need / People when entries support it). |
| **Action** | **Prompt for today**, normally **informed by Thinking**; **Thinking and Action may be produced independently** in implementation (e.g. if Thinking fails a quality gate, Action can still be grounded in Observation alone). |

Default prompt strategy: generate **Observation → Thinking → Action** in that order; allow **decoupled** Action when needed for robustness.

### Angle G — Length, hierarchy, and scan (Designer-owned numbers)

**Strategist lock:**

- **Hard caps** per section (character and/or sentence limits): **Designer** specifies exact numbers in the **#40** spec; **Builder** enforces in UI (truncation, clamp, or dynamic type–aware limits as agreed).
- **Source** (`AI` / `On-device`): show **once** for the whole insight card (not per section) in **v1**.
- **Future:** User or Settings **toggle** for source placement (e.g. per-section) is **out of v1**; tracked as **#83** (optional placement for AI / On-device source label).

### Angle H — Marketing and naming (labels must not over-promise)

**Marketing** checks that section titles do not imply clinical depth, mandatory homework, or precision the engine cannot guarantee.

**Shipped strings (en + zh-Hans)** live in `GraceNotes/GraceNotes/Localizable.xcstrings` — keys **`This week`**, **`A thread`**, **`A next step`** (see `design.md` **Localization**).

**Suggested English labels (starting point for Translator / Marketing):**

| Section | Suggested `en` label | Notes |
|---------|---------------------|--------|
| Observation | **This week** | Concrete, time-bounded; matches the seven-day window. |
| Thinking | **A thread** | Implies connection across signals without “analysis” or “AI insight.” |
| Action | **A next step** | Forward-looking without sounding like a task list. |

**Chosen `zh-Hans` section labels (Translator + Marketing):** **本周** / **发现** / **下一步**—pair with the same intent as `en` (**This week** / **A thread** / **A next step**); parity on promise, not word-for-word.

### Outcomes tracker

| Angle | Status | Conclusion (one line) |
|-------|--------|------------------------|
| A Epistemic | **Closed** | Thinking is grounded in Observation and ≥1 step beyond; no duplicate fact in Thinking. |
| B User job | **Closed** | All sections visible; Thinking must earn space via A, not by user “skipping.” |
| C v1 mapping | **Closed** | Light week → Observation = one line; lists optional; table is v1 default. |
| D Evidence | **Closed** | Thin data: all three sections, shorter/softer copy. |
| E Tone / safety | **Closed** | Forbidden list and/or second validation pass; Architect picks in #80. |
| F Cross-column | **Closed** | Observation = facts; Thinking = relations; Action from Thinking when possible, decoupled if needed. |
| G Length / scan | **Closed** | Hard caps in design spec; source once in v1; source UI toggle → future issue. |
| H Marketing | **Closed** | `en`: **This week** / **A thread** / **A next step**; `zh-Hans`: **本周** / **发现** / **下一步**. |

## Rationale

- **#80** is correctly scoped as **sustained engine iteration** against the quality contract; without a sharper product story, iteration risks tuning wording that still feels generic or overreaches.
- The trio **Observation → Thinking → Action** matches how people reflect: notice → make modest sense → carry one step forward. It also aligns with the contract’s existing trio (**narrative**, **resurfacing**, **continuity**) while giving room to name **anomalies** and **cross-column** links explicitly in **Observation** and **Action**.
- **Thinking** is the riskiest layer (too shallow = “I already knew that”; too deep = wrong or intrusive). Naming it as its own beat makes it easier to cap depth in prompts and examples.

## Risks

- **Terminology drift** — If UI or docs say “观察 / 思考 / 行动” or similar while the technical contract still says `narrativeSummary` / `resurfacingMessage` / `continuityPrompt`, teams must keep a **published mapping** (see `architecture.md` in this folder).
- **Scope creep via Action** — Action must stay **optional in spirit** when evidence is thin: **one** primary question, not a plan for the user’s week.
- **Contract lock** — Post–0.5.0, the quality contract is treated as **locked unless intentionally revised**. Any new required field (e.g. a separate **Thinking** string) is a **contract change**, not a wording tweak.

## Principles (guardrails)

- **Faithful > clever** — Prefer a smaller true observation over a sweeping interpretation.
- **AI optional; on-device baseline** — Same as the contract; low-entry weeks stay deterministic.
- **Calm, non-judgmental** — Especially for anomalies (“you mentioned X less this week”) without implying failure.
- **One continuity move** — At most one primary **Action** prompt per weekly insight surface unless product explicitly expands later.
- **Gratitude-loop friendly** — Action should be phrased so it *can* become a gratitude, a need, or a person-in-mind line—not only abstract reflection.

## Open Questions

- **Outcomes tracker (A–H):** closed in **Three sections: content definition** unless Strategist reopens an angle.
- **Resolved for v1:** Thinking stays **merged** into `narrativeSummary` (plus existing resurfacing); three beats are **IA + labels** within one insight, not a new JSON key.
- **Follow-up (not v1):** optional **source label placement** toggle — **#83**.
- What **minimum evidence** is required before naming an **anomaly** (e.g. drop in mentions of a person) so we avoid noisy false alarms? *(Prototype default for **#80**: defer explicit anomaly copy in v1 unless thresholds are easy; ship recurring + resurfacing first, add anomaly when tests exist.)*
- For **Action**, do we standardize on **one** pattern (e.g. always a question) or allow a short **invitation** line plus optional question? *(Prototype default: **one primary question**; optional one short invitation **only** if Marketing/Designer agree it stays scannable.)*

## Next Owner

**Archived 2026-03-25** — Planning and design spec are complete. **Implementation** continues in active initiative **[017-issue-40-80-insight-implementation](../../017-issue-40-80-insight-implementation/)** (GitHub **#40** then **#80**, serial).

**Artifacts for build (still authoritative):** same-folder `design.md`, `architecture.md`, this `brief.md`, and **section title** strings in `Localizable.xcstrings` — keys: `This week`, `A thread`, `A next step` (see `design.md`).
