---
initiative_id: 016-issue-80-insight-direction
role: Strategist
status: in_progress
updated_at: 2026-03-25
related_issue: 80
related_pr: none
---

# Pushback

## Entry 1

- `Constraint`: Planning-only initiative; no implementation or contract file edits until product direction is agreed.
- `Current Impact`: None — upstream framing work for **#80**.
- `Not-Now Decision`: Defer any pushback on engine implementation until `brief.md` and contract-bridge `architecture.md` are reviewed.
- `Revisit Trigger`: *(Superseded by Entry 2.)*

## Entry 2

- `Constraint`: Same planning boundary; engine/UI work tracks **#80** / **#40**, not open questions in this file.
- `Current Impact`: **Thinking / v1 contract** — Strategist locked **v1**: no new JSON keys; **Thinking** is copy discipline in **`narrativeSummary`** (plus existing resurfacing rules). See `brief.md` **Product decisions** and **Open Questions** (resolved for v1).
- `Not-Now Decision`: A dedicated **Thinking** string field remains **v2+** only with explicit contract + sanitizer + tests.
- `Revisit Trigger`: If user research or quality still fails after **#40** + **#80** ship, reopen as a **new** Strategist decision (not this entry).
