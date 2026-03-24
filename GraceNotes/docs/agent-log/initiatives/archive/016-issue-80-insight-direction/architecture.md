---
initiative_id: 016-issue-80-insight-direction
role: Architect
status: in_progress
updated_at: 2026-03-25
related_issue: 80
related_pr: none
---

# Architecture: Contract bridge (Observation / Thinking / Action)

This file is **not** an implementation design. It maps the **product frame** in `brief.md` to the **current Review insight contract** (`03-review-insight-quality-contract.md`) and classifies what would change under **#80** vs **#40** vs future exploration.

## Inputs Reviewed

- `GraceNotes/docs/agent-log/initiatives/archive/016-issue-80-insight-direction/brief.md`
- `GraceNotes/docs/03-review-insight-quality-contract.md`
- `GraceNotes/docs/04-review-insight-examples.md`
- `GraceNotes/docs/agent-log/initiatives/archive/014-release-0-5-0-insight-quality/architecture.md`

## Decision

**Strategist lock-in (v1)** — See `brief.md` **Product decisions** and **Three sections: content definition**. Highlights: **Observation = facts**; **Thinking = relationships**, grounded in Observation and **≥1 step beyond** it; **Action** usually informed by Thinking but **may be generated independently** (e.g. fallback). **Light week:** Observation collapses to **one line**; **all three section headers** remain with shorter copy. **Source** label **once** per card; **hard caps** per section in **#40** spec.

**Default mapping (no new JSON keys)** — Keep the existing payload shape and gates; interpret the three beats **semantically**:

| Product beat (brief) | Current contract field(s) | Role |
|----------------------|---------------------------|------|
| **Observation** | `recurringGratitudes`, `recurringNeeds`, `recurringPeople`, and the **factual** part of `resurfacingMessage` | **Facts only** for the window; anomaly-style copy here only when gated. |
| **Thinking** | Primarily `narrativeSummary`; optionally the **interpretive** clause of `resurfacingMessage` if kept short and grounded | **Relationships** across Observation; grounded, non-clinical tone per `04-review-insight-examples.md` (connector persona). |
| **Action** | `continuityPrompt` | Single next-step question or invitation; aligned with “carry momentum forward” in the contract. |

**Optional future mapping (contract expansion)** — If Strategist + Designer agree that **Thinking** must be **visually and structurally** separate:

- Add a dedicated string field (name TBD) to the JSON contract, extend sanitizer/gates, and treat **#80** + contract doc update as one intentional revision.
- **#40** (or a follow-on) owns how three beats are **shown**; **#80** owns generation quality and conformance tests.

Until that decision is explicit, treat **Thinking** as **narrative copy discipline**, not a new required key.

## Rationale

- The shipped contract already encodes **specificity, faithfulness, calm tone, one continuity prompt, scannability, transparency**, and **thin-evidence** behavior. The new frame should **reduce generic feel** without throwing away those gates.
- **Resurfacing** in examples is often a **pure count** (“You mentioned rest 4 times”)—that is **Observation**. When narrative and resurfacing overlap, merging interpretation into `narrativeSummary` keeps **one** place for “why these observations belong in one sentence.”
- **Action** maps cleanly to `continuityPrompt`, which the contract already limits to **one** clear prompt or question.

## Risks

- **Anomaly detection** in **Observation** may be hard to gate; without clear thresholds, sanitizer/tests for **#80** become brittle or overfit.
- Splitting **Thinking** into a new field without UI clarity could **increase** cognitive load; three blocks must still feel like **one** scannable card per the contract.

## Bucket: What stays valid today

- Seven-day review period definition and comparison to **prior seven days** for continuity-style patterns (`03-review-insight-quality-contract.md`).
- Low-entry rule: **&lt; 3 meaningful entries** → skip cloud path; deterministic baseline.
- Required JSON keys: `narrativeSummary`, `resurfacingMessage`, `continuityPrompt`, recurring theme lists.
- Quality gates philosophy: anti-generic continuity, recurring labels referenced in messages, fallback on failure.

## Bucket: Wording / prompt craft only (still **#80**)

- Rewriting prompts so **narrative** reads as **Thinking** (one grounded synthesis) without new schema.
- Tuning **resurfacing** to include **pattern + anomaly** language when evidence supports it.
- Tuning **continuity** so it **bridges to Today** (gratitude / need / people) while staying a **single** continuity prompt.
- Fixture audits and tests that encode the new tone and specificity bar.

## Bucket: Contract or UI change (explicit decision; coordinates **#80** + **#40**)

- **v1 (decided):** **#40** — three **labeled sections within one** insight surface; still one scannable weekly unit; no new payload keys.
- **v2+ (explicit revision only):** New payload field for **Thinking** or **Observation** split; would require contract doc + sanitizer + tests + Marketing check on promises.
- Stronger **anomaly** logic that might need **new tests** and **user-facing explanations** of why something was flagged.

## Open Questions

- **Thresholds for anomalies** — e.g. minimum baseline frequency in prior window vs current window; require human-readable “why” in copy. *(Brief: defer explicit anomaly in v1 unless cheap to gate.)*
- **Cross-column Action** — Brief **F** allows Action decoupled from Thinking; still TBD whether default prompt **prefers one column** vs neutral wording—**Designer** + **#80** fixtures.
- **Numeric hard caps** — Exact character/sentence limits live in **#40** spec once Designer publishes them.

## Next Owner

**Archived** — Implementation continues in **[017-issue-40-80-insight-implementation](../../017-issue-40-80-insight-implementation/)**; **Architect** reads this folder first, then owns **`architecture.md`** there. Section title strings are already in `Localizable.xcstrings` (`This week`, `A thread`, `A next step`).
