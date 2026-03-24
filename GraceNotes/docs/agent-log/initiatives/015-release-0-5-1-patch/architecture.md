---
initiative_id: 015-release-0-5-1-patch
role: Architect
status: in_progress
updated_at: 2026-03-24
related_issue: none
related_pr: none
---

# Architecture

## Inputs Reviewed

- `brief.md` (015) — ship-the-CHANGELOG patch, version/doc gates.
- `CHANGELOG.md` `[0.5.1]` — full technical and user-facing bullet list.
- `AGENTS.md` — boundaries, test command, SwiftLint note.

## Goals

- **Upgrade orientation:** First launch on **0.5.1** after an older marketing version shows the correct journey: below Seed → full guided chip path; at/above Seed → post-Seed settings-oriented path **without** Seed congratulations. `lastLaunchedMarketingVersion` and deferred `completedGuidedJournal` migration behave as described in CHANGELOG.
- **Copy / localization:** `Localizable.xcstrings`, `Info.plist` / `InfoPlist.xcstrings`, and `String(localized:)` call sites stay consistent; en uses American English where specified; zh-Hans tone and 感恩记 usage match CHANGELOG.
- **Cloud / locale:** `AppInstructionLocale` used for chip summarization and Review `.automatic` language; low-signal keyboard mash skipped; grounding/filler rejection unchanged in intent from CHANGELOG.
- **Stability / UI chrome:** iOS 17 startup path via `UIApplicationDelegate`; Dynamic Type caps on tab bar and navigation chrome per #76.
- **Build / packaging:** Marketing **0.5.1**, bundle **3**; Debug/Demo dSYM; scheme Release for Run; Swift strict concurrency **minimal** and removed experimental flags as in CHANGELOG; `DeveloperSettings` / encryption plist as documented.

## Non-Goals

- Expanding insight presentation or engine work beyond what is already in tree for this tag.
- Reverting or redesigning onboarding architecture for a later milestone inside this patch initiative.

## Technical Scope

- App targets: version fields in Xcode project; onboarding/orientation state (`lastLaunchedMarketingVersion`, completion/journal storage keys).
- String catalogs and plist localizations; summarizer provider tests and UI-test launch flags/identifiers referenced in CHANGELOG Developer section.
- Build settings: `DEBUG_INFORMATION_FORMAT`, concurrency-related `SWIFT_*` removals, `StartupCoordinator` sendable requirement.

## Affected Areas

- Journal onboarding / orientation flows and Settings deep-links.
- Review (timeline, cloud insights, chip summarization).
- Today tab completion and gratitude chips.
- Settings (Cloud AI, display strings).
- Test bundles: unit tests for cloud prompt/grounding; UI tests for journal persistence, identifiers, locale flags.

## Risks

- **Cohort detection timing** — orientation vs `completedGuidedJournal` migration when Today completion is unknown on first launch after upgrade.
- **Developer scheme** — Release Run may hide Debug-only issues; document local revert.
- **Secrets / CI** — `ApiSecrets.cloudApiKeyOverrideForTesting` and plist key expansion must not break CI or local test runs.

## Sequencing

1. Confirm **main** contains all CHANGELOG-listed behavior (no dangling PRs for 0.5.1 scope).
2. **Test Lead:** automated suites + manual matrix on macOS.
3. **QA Reviewer:** requirement fit vs brief + changelog.
4. **Release Manager:** cut `release/0.5.1` if using branch workflow, date CHANGELOG, tag **`v0.5.1`**.

## Close Criteria

- `xcodebuild` **test** for scheme GraceNotes passes on a current iOS Simulator (see `AGENTS.md` command).
- SwiftLint run per repo practice; no new error-level violations required for merge/tag policy (project baseline may still have known warnings).
- Manual passes: upgrade orientation (both cohorts), large Dynamic Type chrome spot-check, Save to Photos / permission copy smoke in en and zh-Hans if touched.
- Version strings: **0.5.1** / **3** in project; CHANGELOG/README/roadmap match `release.md`.

## Decision

Technical delivery for 0.5.1 is **CHANGELOG-complete on `main`** plus **verified tests and manual matrix** before tag.

## Rationale

Patch risk is spread across onboarding state, strings, cloud calls, and build settings; automated tests plus a short manual matrix cover the highest regression surfaces without re-architecting.

## Open Questions

- None blocking architecture; product/policy questions live in `brief.md` / `release.md` (scheme Run configuration).

## Next Owner

**Test Lead** — Own `testing.md`: risk map, execution results on macOS, Go/No-Go. **Builder** only if suites or manual pass finds regressions.
