import XCTest
@testable import GraceNotes

final class JournalTutorialUnlockEvaluatorTests: XCTestCase {
    func test_outcome_noneToQuickCheckIn_firstSeed() {
        let outcome = JournalTutorialUnlockEvaluator.outcome(
            previousRank: JournalCompletionLevel.none.tutorialCompletionRank,
            newRank: JournalCompletionLevel.quickCheckIn.tutorialCompletionRank,
            newLevel: .quickCheckIn,
            hasCelebratedFirstSeed: false,
            hasCelebratedFirstHarvest: false
        )
        XCTAssertTrue(outcome.recordFirstSeedCelebrated)
        XCTAssertFalse(outcome.recordFirstHarvestCelebrated)
        XCTAssertEqual(outcome.milestoneHighlight, .firstSeed)
    }

    func test_outcome_quickCheckInToStandard_firstHarvest() {
        let outcome = JournalTutorialUnlockEvaluator.outcome(
            previousRank: JournalCompletionLevel.quickCheckIn.tutorialCompletionRank,
            newRank: JournalCompletionLevel.standardReflection.tutorialCompletionRank,
            newLevel: .standardReflection,
            hasCelebratedFirstSeed: true,
            hasCelebratedFirstHarvest: false
        )
        XCTAssertFalse(outcome.recordFirstSeedCelebrated)
        XCTAssertTrue(outcome.recordFirstHarvestCelebrated)
        XCTAssertEqual(outcome.milestoneHighlight, .firstFifteenChipHarvest)
    }

    func test_outcome_noneToStandard_rankSkip_recordsBoth_highlightsHarvest() {
        let outcome = JournalTutorialUnlockEvaluator.outcome(
            previousRank: JournalCompletionLevel.none.tutorialCompletionRank,
            newRank: JournalCompletionLevel.standardReflection.tutorialCompletionRank,
            newLevel: .standardReflection,
            hasCelebratedFirstSeed: false,
            hasCelebratedFirstHarvest: false
        )
        XCTAssertTrue(outcome.recordFirstSeedCelebrated)
        XCTAssertTrue(outcome.recordFirstHarvestCelebrated)
        XCTAssertEqual(outcome.milestoneHighlight, .firstFifteenChipHarvest)
    }

    func test_outcome_noneToFullFiveCubed_rankSkip_recordsBoth_highlightsHarvestWithRhythm() {
        let outcome = JournalTutorialUnlockEvaluator.outcome(
            previousRank: JournalCompletionLevel.none.tutorialCompletionRank,
            newRank: JournalCompletionLevel.fullFiveCubed.tutorialCompletionRank,
            newLevel: .fullFiveCubed,
            hasCelebratedFirstSeed: false,
            hasCelebratedFirstHarvest: false
        )
        XCTAssertTrue(outcome.recordFirstSeedCelebrated)
        XCTAssertTrue(outcome.recordFirstHarvestCelebrated)
        XCTAssertEqual(outcome.milestoneHighlight, .firstFifteenChipHarvestWithFullRhythm)
    }

    func test_outcome_firstSeedAlreadyCelebrated_noDuplicateRecord() {
        let outcome = JournalTutorialUnlockEvaluator.outcome(
            previousRank: JournalCompletionLevel.none.tutorialCompletionRank,
            newRank: JournalCompletionLevel.quickCheckIn.tutorialCompletionRank,
            newLevel: .quickCheckIn,
            hasCelebratedFirstSeed: true,
            hasCelebratedFirstHarvest: false
        )
        XCTAssertFalse(outcome.recordFirstSeedCelebrated)
        XCTAssertEqual(outcome.milestoneHighlight, .none)
    }

    func test_outcome_standardToFull_noHarvestRecordWhenAlreadyCelebrated() {
        let outcome = JournalTutorialUnlockEvaluator.outcome(
            previousRank: JournalCompletionLevel.standardReflection.tutorialCompletionRank,
            newRank: JournalCompletionLevel.fullFiveCubed.tutorialCompletionRank,
            newLevel: .fullFiveCubed,
            hasCelebratedFirstSeed: true,
            hasCelebratedFirstHarvest: true
        )
        XCTAssertEqual(outcome, JournalTutorialUnlockEvaluator.Outcome.neutral)
    }

    func test_outcome_rankUnchanged_returnsNeutral() {
        let outcome = JournalTutorialUnlockEvaluator.outcome(
            previousRank: 1,
            newRank: 1,
            newLevel: .quickCheckIn,
            hasCelebratedFirstSeed: false,
            hasCelebratedFirstHarvest: false
        )
        XCTAssertEqual(outcome, JournalTutorialUnlockEvaluator.Outcome.neutral)
    }
}
