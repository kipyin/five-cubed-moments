# Agent Log Index

`agent-log` is the canonical place for cross-role coordination.

## Active Initiatives

- [`issue-71-guided-onboarding`](initiatives/issue-71-guided-onboarding) — PR **#79** / epic **#71** (`qa.md`, `testing.md`)
- [`release-0-5-1-patch`](initiatives/release-0-5-1-patch) — **0.5.1** patch line, integrate from **`main`** (`release.md`)

## Shipped reference (archived handoffs)

- [`release-0-5-0-insight-quality`](initiatives/release-0-5-0-insight-quality) — **0.5.0** shipped **2026-03-21** (`brief.md`, `architecture.md`, `testing.md`)
- [`issue-60-guided-tutorial`](initiatives/issue-60-guided-tutorial) — first-run Seed/Harvest hints (`#60`), shipped in **0.5.0** (`release.md` is historical)
- [`issue-31-33-launch-toggle-performance`](initiatives/issue-31-33-launch-toggle-performance) — **0.3.2** startup/reminder/input (`release.md` is historical)
- [`issue-41-agents-workflow`](initiatives/issue-41-agents-workflow) — agent-log workflow shipped via PR **#49** (`release.md`); **Strategist** may revisit adoption/blocking later

## Initiative Directory Convention

Use a stable slug, usually `issue-<number>-<short-topic>`:

- `GraceNotes/docs/agent-log/initiatives/issue-41-agents-workflow`

## Fast Path (small changes)

For small changes, add one concise update with:

- `Decision`
- `Open Questions` (`None` if no blockers)
- `Next Owner`

## Full Path (multi-day or high-risk)

For larger efforts, keep role files in the initiative folder:

- `brief.md`
- `design.md` (optional; **Designer** output for UI-heavy work — specs and acceptance for front end)
- `architecture.md`
- `qa.md`
- `testing.md`
- `release.md`
- `pushback.md` (optional)
