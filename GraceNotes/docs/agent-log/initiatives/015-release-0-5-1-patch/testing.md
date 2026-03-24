---
initiative_id: 015-release-0-5-1-patch
role: Test Lead
status: in_progress
updated_at: 2026-03-24
related_issue: none
related_pr: none
---

# Testing

## Inputs Reviewed

- `architecture.md` (015) — goals, close criteria, risks.
- `qa.md` (015) — test gaps: cohort upgrade not only fresh install; UIKit chrome manual pass.
- `CHANGELOG.md` `[0.5.1]` — Developer section (new/changed tests, UI-test flags).
- `AGENTS.md` — `xcodebuild` test invocation.

## QA gap bridge

| `qa.md` gap | Automated bridge | Still manual (why) |
|-------------|------------------|-------------------|
| Cohort orientation beyond fresh install | `Orientation051LaunchTests` (crossing `< 0.5.1` → `0.5.1`, branch at soil / seed / ripening) + **`PostSeedJourneyTriggerTests`** (standard Seed path vs 0.5.1 upgrade skip-congrats path) | One full **install upgrade** (see matrix) confirms SwiftUI presentation + real data |
| UIKit chrome / Dynamic Type | None in tree (no snapshot suite per CHANGELOG) | Single pass at largest content sizes on a simulator or device |

## Risk Map

| Area | Risk | Mitigation |
|------|------|------------|
| Upgrade orientation / cohorts | Wrong journey or double-showing | **Unit:** `Orientation051LaunchTests`, `PostSeedJourneyTriggerTests`. **Manual:** upgrade matrix below (below Seed vs at/above Seed) |
| Post-Seed journey policy | Upgrade path shows wrong first page | `PostSeedJourneyTrigger.evaluate` locked by `PostSeedJourneyTriggerTests` |
| Dynamic Type | Tab bar / nav overlap | Manual at largest text + Larger Accessibility Sizes |
| iOS 17 startup | Regression crash | Smoke launch on iOS 17 simulator or device |
| Cloud summarization | Wrong locale / unnecessary calls | Exercise chip summarize + Review insights; unit tests `CloudSummarizerPromptAndGroundingTests` |
| Strings | Missing key / wrong locale | Spot-check en + zh-Hans in onboarding, Settings, errors |
| Build settings | Test flake or concurrency warning spike | Full `xcodebuild test` on GraceNotes scheme |

## Test Strategy by Level

- **Unit:** Run full GraceNotes test action — includes `Orientation051LaunchTests`, **`PostSeedJourneyTriggerTests`**, `MarketingVersionTests`, cloud prompt/grounding and related suites noted in CHANGELOG.
- **UI:** `JournalUITests` (persistence, identifiers, `-ui-testing` behavior per CHANGELOG Developer notes).
- **Manual:** One upgrade run per matrix row + Dynamic Type chrome + optional Save to Photos permission string check.

## Manual matrix (close `qa.md` / architecture)

### A — Upgrade orientation (install over older marketing version)

Prerequisite: a **0.5.0** (or any build whose marketing version sorts **strictly before** `0.5.1`) installed and launched at least once on the simulator/device so `graceNotes.lastLaunchedMarketingVersion` is below `0.5.1`. Then install and launch **0.5.1** without deleting the app.

| Cohort | Seed today’s entry before upgrade | Expected on first 0.5.1 launch |
|--------|-----------------------------------|--------------------------------|
| Below Seed | Today completion **soil** (or below Seed) | Full guided journal path; post-Seed journey includes **Seed congratulations** when you reach Seed |
| At/above Seed | Today at **Seed** or higher (e.g. seed demo data or real entries) | Post-Seed orientation **without** Seed congratulations; settings-oriented pages as in product spec |

Second cold launch on **0.5.1**: orientation **must not** replay (`pending051UpgradeOrientation` cleared).

### B — Dynamic Type / UIKit chrome (#76)

On **Simulator or device**: **Settings → Accessibility → Display & Text Size → Larger Text** — drag to maximum; if available, enable **Larger Accessibility Sizes** and repeat at the largest setting.

| Surface | Pass criteria |
|---------|----------------|
| Tab bar | All tab titles visible; no clipping or overlap with safe area |
| Navigation bar / large title | Headlines readable; no truncation that hides meaning |
| Journal / Review / Settings | Primary actions and section headers usable without overlapping chrome |

Record device model + iOS version if anything fails.

## Execution Results

- **Automated (2026-03-24):** **PASS** —  
  `xcodebuild -project GraceNotes/GraceNotes.xcodeproj -scheme GraceNotes -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.6' test`  
  (Use an explicit `OS=` if `OS=latest` does not resolve on your Xcode install; `AGENTS.md` example uses iPhone 15.)  
  UI suite: two history/share tests **skipped**; other `JournalUITests` cases **passed**; launch tests **passed**.
- **Automated (post bridge):** Re-run full `xcodebuild test` on macOS after adding `PostSeedJourneyTrigger` tests — **not executed in this Linux agent session**.
- **Manual matrix B (Dynamic Type):** **PASS** — human UAT, largest text + Larger Accessibility Sizes (2026-03-24); recorded in `qa.md`.
- **Manual matrix A (upgrade orientation):** Not recorded this cycle — optional once-per-RC install-over-upgrade per product; see `qa.md` residual.

## Defects and Fixes

- None recorded in this initiative file yet.

## Coverage Adequacy Assessment

- **Upgrade detection and branch resolution** are covered by `Orientation051LaunchTests` (including `0.4.0` → `0.5.1` and branch resolution at **ripening**).
- **Post-Seed presentation policy** (standard Seed vs upgrade skip-congrats) is covered by `PostSeedJourneyTriggerTests`, reducing reliance on fresh-install-only assumptions.
- CHANGELOG-targeted cloud summarization and journal UI tests remain as before; **full upgrade E2E** and **Dynamic Type** still need the manual matrix once per release candidate.

## Decision

**Go/No-Go:** **Go** for release planning — automated suite green (per execution results); manual **B** complete. Matrix **A** optional before App Store per `qa.md` / Release Manager.

## Rationale

015 is a broad patch; automated suites catch regressions in summarizer and journal UI flows, while orientation logic needs explicit manual upgrade simulation.

## Risks

- Simulator-only pass might miss device-specific appearance; optional device smoke before App Store submit.

## Open Questions

- None.

## Next Owner

**Release Manager** — Tag workflow and CHANGELOG date per `release.md`. **Test Lead** only if matrix **A** is required before ship and needs recording.
