---
initiative_id: 023-onboarding-first-entry-policy
role: Architect
status: implemented
updated_at: 2026-03-25
---

# Architecture: Today orientation policy

## Decision

Centralize **Today-only** rules for the post-Seed full-screen journey and Seed unlock toast suppression in `JournalTodayOrientationPolicy` ([`JournalTodayOrientationPolicy.swift`](../../../../GraceNotes/Features/Journal/Tutorial/JournalTodayOrientationPolicy.swift)). `JournalScreen` builds `Inputs` and applies side effects (present cover, skip toast); eligibility details remain in `PostSeedJourneyTrigger`.

## Product matrix (Today, `entryDate == nil`)

| Situation | Post-Seed journey | Notes |
|-----------|-------------------|--------|
| Not yet seen **C** (`hasSeenPostSeedJourney == false`), completion **≥ Seed** | Yes (hard interrupt when appropriate) | Skip Seed congratulations page when `completedGuidedJournal` is already true |
| Already seen **C** (Today finish or Settings **App tour**) | No | `hasSeenPostSeedJourney` |
| UI tests | No | `isRunningUITests` |
| Historical date (`entryDate != nil`) | No | `isTodayEntry == false` |

**Settings path:** Finishing or skipping the journey from Settings sets `hasSeenPostSeedJourney` only (not `completedGuidedJournal`), so users who only watched **C** from Help stay on guided **B** until they complete the journal or reach Abundance.

**Versioning:** No marketing/build gate for **C**. Legacy `journalOnboarding.pending051*` keys are removed on launch via `JournalOnboardingProgress.migrateLegacyPostSeedOrientationFlagsIfNeeded`. `AppLaunchVersionTracker` persists last launched marketing/bundle for continuity/support only.

## Dual completion

Guided first entry coaching ends when **either**:

1. Today reaches **Abundance** (`syncGuidedJournalCompletionIfNeeded` sets `completedGuidedJournal`), or  
2. User **finishes** the post-Seed journey from **Today** (`completePostSeedJourney` sets `completedGuidedJournal` and `hasSeenPostSeedJourney`).

## Open Questions

- Optional future Strategist pass: decouple “first entry complete” from `completedGuidedJournal` vs post-Seed finish behind one flag. **Not** done in this slice.

## Next Owner

`QA` / manual smoke: fresh install to Seed; Settings **App tour** then confirm auto **C** does not repeat; heavy journal user with `hasSeen` false gets **C** once on Today.
