---
initiative_id: issue-71-guided-onboarding
role: QA Reviewer
status: in_progress
updated_at: 2026-03-23
related_issue: 71
related_pr: 79
---

# QA — PR #79 vs `release/0.5.1` (reevaluation)

## Context

- PR [#79](https://github.com/kipyin/grace-notes/pull/79) → base `release/0.5.1`; epic [#71](https://github.com/kipyin/grace-notes/issues/71).
- Agent log: [testing.md](testing.md) (no initiative `brief.md` / `architecture.md` for #71; intent from GitHub epic + code).
- **Evidence this pass**: full `xcodebuild test` **succeeded** on `platform=iOS Simulator,name=iPhone 15,OS=17.5` (2026-03-23). PR GitHub rollup: Cursor automation check **SUCCESS** (still no separate hosted xcodebuild CI in rollup).

## Requirement coverage

- **Behavior-first first journal**: `JournalOnboardingFlowEvaluator` + `JournalScreen` locking/focus; covered by `JournalOnboardingFlowEvaluatorTests`.
- **Post–Seed journey**: `PostSeedJourneyView`; presented at Seed on Today; **UITests skip the cover** via `ProcessInfo.graceNotesIsRunningUITests` so automated Today flows stay stable — product path still needs manual check in [testing.md](testing.md).
- **Milestone suggestions → Settings**: `JournalOnboardingSuggestionEvaluator`, `AppNavigationModel`, `JournalScreen.openSettings(for:)`; evaluator unit-tested; navigation not UI-automated end-to-end.
- **iCloud default / upgrade continuity**: `ICloudSyncPreferenceResolver` + `PersistenceController`; unit tests for main branches; not every continuity key individually asserted.

**Gaps vs epic #71**

- Epic acceptance (“complete sequence without reading tutorial”, a11y, zh/en) still relies on **manual** execution of [testing.md](testing.md).
- Whether one PR should **close** the whole epic remains a **process** question (#71 may stay open for follow-ups).

## Behavior and regression risks

| Risk | Severity | Notes |
|------|-----------|--------|
| UITest vs real user: post-Seed hidden in UI tests | Medium | Real users still see full-screen journey; regressions there are **not** caught by `JournalUITests`. |
| `JournalScreen` surface area | Medium | Toasts, hints, onboarding, suggestions share one view — rely on unit tests + manual smoke for integration. |
| Skip/Done ends guided journal + dismisses suggestions | Low–Med (product) | **Documented as intentional** in `PostSeedJourneyView` and prior Strategist record below. |
| `fullScreenCover` interactive dismiss | Low | Unverified edge path; low likelihood on phone. |
| `@AppStorage` key literals vs `JournalTutorialStorageKeys` | Low | Drift risk only. |

**Mitigations verified in code/tests**

- Seed unlock toast suppressed when post-Seed would show (non–UI-test runs).
- `-reset-journal-tutorial` resets onboarding progress.
- Today UI tests: stable launch args, English locale, chip accessibility ids, persistence across terminate/launch.

## Code quality gaps

- `JournalScreen` still uses string literals for two `journalTutorial.*` keys instead of `JournalTutorialStorageKeys`.
- Large `PostSeedJourneyView*` stack without dedicated UI tests for pages/toggles.
- PR title remains generic for reviewers.

## Test gaps

- No `XCTest`/`UITest` for post-Seed pages, Skip/Done, or in-journey toggles.
- `ICloudSyncPreferenceResolver`: individual continuity keys not each unit-tested.
- No automated test for suggestion tap → Settings scroll/highlight.
- Two `JournalUITests` remain **skipped** (timeline row exposure), unrelated to #71 but limits regression signal on Review navigation.

## Pass / fail recommendation

**Pass (automated merge gate)** — full scheme **TEST SUCCEEDED** on iPhone 15 / iOS 17.5 Simulator; unit + executed UI tests green.

**Conditional** on **release** until: [testing.md](testing.md) manual smokes are run (post-Seed, Settings deep links, fresh iCloud default), and **Translator** signs off **zh-Hans** if 0.5.1 ships localized copy.

## Decision

- **Merge / CI automation**: **Pass** (objective: `xcodebuild test` green as above).
- **Full epic #71 acceptance**: **Open** — complete manual checklist + localization as above.

## Strategist record — Skip / Done on post–Seed journey

**Product-as-coded:** Skip or Done ends the full-screen journey **and** the guided tutorial (`hasCompletedGuidedJournal`), and dismisses milestone suggestion flags — explicit opt-out. Change requires **Builder** + **Strategist** if Ripening→Abundance guidance must continue after dismiss.

## Open questions

- Close #71 entirely vs leave open for child items?
- Add UI tests that **drive** post-Seed (not only skip under `graceNotesIsRunningUITests`)?

## Next owner

- **Test Lead**: Run and tick off [testing.md](testing.md); note date in that file.
- **Translator**: zh-Hans spot-check for new strings.
- **Release Manager**: Treat automated gate as satisfied; track manual/translation for ship checklist.
