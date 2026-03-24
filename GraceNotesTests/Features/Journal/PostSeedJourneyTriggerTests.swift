import XCTest
@testable import GraceNotes

final class PostSeedJourneyTriggerTests: XCTestCase {
    func test_evaluate_whenAlreadySeen_returnsNil() {
        let outcome = PostSeedJourneyTrigger.evaluate(
            hasSeenPostSeedJourney: true,
            pending051UpgradeOrientation: true,
            hasCompletedGuidedJournal: true,
            todayCompletionLevel: .seed
        )
        XCTAssertNil(outcome)
    }

    func test_evaluate_standardNewUserAtSeed_showsWithCongratulations() {
        let outcome = PostSeedJourneyTrigger.evaluate(
            hasSeenPostSeedJourney: false,
            pending051UpgradeOrientation: false,
            hasCompletedGuidedJournal: false,
            todayCompletionLevel: .seed
        )
        XCTAssertEqual(outcome?.skipsCongratulationsPage, false)
    }

    func test_evaluate_belowSeed_neverShows() {
        for pending in [false, true] {
            let outcome = PostSeedJourneyTrigger.evaluate(
                hasSeenPostSeedJourney: false,
                pending051UpgradeOrientation: pending,
                hasCompletedGuidedJournal: false,
                todayCompletionLevel: .soil
            )
            XCTAssertNil(outcome, "expected nil for soil pending=\(pending)")
        }
    }

    func test_evaluate_upgradeAtSeed_beforeGuidedResolved_showsWithCongratulations() {
        let outcome = PostSeedJourneyTrigger.evaluate(
            hasSeenPostSeedJourney: false,
            pending051UpgradeOrientation: true,
            hasCompletedGuidedJournal: false,
            todayCompletionLevel: .seed
        )
        XCTAssertEqual(outcome?.skipsCongratulationsPage, false)
    }

    func test_evaluate_upgradeAtOrAboveSeed_afterGuidedResolved_skipsCongratulations() {
        for level in [JournalCompletionLevel.seed, .ripening, .harvest, .abundance] {
            let outcome = PostSeedJourneyTrigger.evaluate(
                hasSeenPostSeedJourney: false,
                pending051UpgradeOrientation: true,
                hasCompletedGuidedJournal: true,
                todayCompletionLevel: level
            )
            XCTAssertEqual(
                outcome?.skipsCongratulationsPage,
                true,
                "level \(level) should skip congrats for upgrade + guided complete"
            )
        }
    }

    func test_evaluate_notUpgrade_aboveSeed_butGuidedIncomplete_doesNotShow() {
        let outcome = PostSeedJourneyTrigger.evaluate(
            hasSeenPostSeedJourney: false,
            pending051UpgradeOrientation: false,
            hasCompletedGuidedJournal: false,
            todayCompletionLevel: .harvest
        )
        XCTAssertNil(outcome)
    }
}
