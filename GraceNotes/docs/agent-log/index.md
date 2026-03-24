# Agent Log Index

`agent-log` is the canonical place for cross-role coordination.

## Active initiatives

- [`issue-71-guided-onboarding`](initiatives/issue-71-guided-onboarding) — PR **#79** / epic **#71** (`qa.md`, `testing.md`)
- [`release-0-5-1-patch`](initiatives/release-0-5-1-patch) — **0.5.1** patch line, integrate from **`main`** (`release.md`)

## Archived initiatives

Shipped or superseded handoffs: [`initiatives/archive/`](initiatives/archive/README.md) (see table there).

## Initiative directory convention

Use a stable slug, usually `issue-<number>-<short-topic>`:

- `GraceNotes/docs/agent-log/initiatives/issue-71-guided-onboarding`

## Fast path (small changes)

For small changes, add one concise update with:

- `Decision`
- `Open Questions` (`None` if no blockers)
- `Next Owner`

## Full path (multi-day or high-risk)

For larger efforts, keep role files in the initiative folder:

- `brief.md`
- `design.md` (optional; **Designer** output for UI-heavy work — specs and acceptance for front end)
- `architecture.md`
- `qa.md`
- `testing.md`
- `release.md`
- `pushback.md` (optional)
