---
initiative_id: 015-release-0-5-1-patch
role: Strategist
status: in_progress
updated_at: 2026-03-24
related_issue: none
related_pr: none
---

# Brief

## Inputs Reviewed

- `CHANGELOG.md` — `[0.5.1] - Unreleased` (upgrade orientation, copy, cloud/locale, fixes, packaging, scheme, concurrency settings).
- `GraceNotes/docs/agent-log/initiatives/015-release-0-5-1-patch/release.md` — branch/tag workflow, marketing `0.5.1`, bundle **3**, doc sync.
- `GraceNotes/docs/07-release-roadmap.md` — 0.5.x line context (referenced from CHANGELOG).

## Problem

Ship **0.5.1** as a controlled patch on **0.5.x**: user-visible copy and onboarding/orientation behavior, stability fixes, and build/packaging hygiene must reach the store with **consistent version strings and docs**, without scope bleed into post-0.5.1 roadmap items.

## User Value

- Clearer product language (en / zh-Hans), calmer chrome at large Dynamic Type, and a **one-time upgrade orientation** that respects Seed vs post-Seed cohorts.
- Fewer crashes (iOS 17 startup) and wasted cloud calls for chips that already fit on-device.
- Trust: marketing version, build number, and release notes match what ships.

## Scope In

- Everything listed under **0.5.1** in `CHANGELOG.md` until that section is dated and tagged **`v0.5.1`**.
- Doc alignment: `CHANGELOG`, `README` “What’s new”, roadmap 0.5.1 blurb, `release.md` checklist.
- **Designer** is **not** a separate gate for this initiative: visual/copy work is already specified in shipped strings and CHANGELOG; no standalone `design.md` unless UI scope expands.

## Scope Out

- Review insight engine redo (**#40** / **#80**) beyond what is already merged for 0.5.1.
- New features targeted at **0.5.2+** unless explicitly pulled into this patch by Strategist/Product.

## Priority Rationale

Patch line continuity: users on **0.5.0** should get orientation + copy + fixes without waiting for the next minor; build **3** and scheme/docs drift are release blockers if inconsistent.

## Acceptance Intent

- **Product:** Upgrade orientation behaves per CHANGELOG cohort rules; copy changes appear in app (en + zh-Hans) where listed; iOS 17 launch stable; Dynamic Type caps behave; cloud chip path matches documented optimizations.
- **Release:** `MARKETING_VERSION` **0.5.1**, `CURRENT_PROJECT_VERSION` **3** on Grace Notes app targets; CHANGELOG **Unreleased** replaced with ship date at tag time; `README` and roadmap match; release workflow in `release.md` followed for branch/tag.

## Decision

Treat **0.5.1** as a **ship-the-CHANGELOG** patch: acceptance is CHANGELOG-backed behavior plus version/doc gates in `release.md`.

## Rationale

The patch bundles many small, user-visible and tooling changes; the single source of truth for “what ships” is the **0.5.1** changelog slice plus Xcode version fields.

## Risks

- **`lastLaunchedMarketingVersion` / cohort edge cases** — support or QA may see unexpected orientation; capture repros (see `release.md` Open Questions).
- **Scheme Run = Release** — team default affects developer workflow; decision is product/engineering policy, not a code defect.

## Open Questions

- Confirm team stance on **`GraceNotes.xcscheme`** Run = **Release** for default ⌘R (see `release.md`).

## Next Owner

**Architect** — Turn this into testable `architecture.md` goals, close criteria, and affected areas keyed to CHANGELOG sections.
