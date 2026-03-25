import XCTest
@testable import GraceNotes

final class JournalTodayOrientationPolicyTests: XCTestCase {

    // MARK: - postSeedJourneyOutcome

    func test_postSeedJourneyOutcome_whenNotToday_returnsNil() {
        let outcome = JournalTodayOrientationPolicy.postSeedJourneyOutcome(
            for: .init(
                isTodayEntry: false,
                isRunningUITests: false,
                hasSeenPostSeedJourney: false,
                hasCompletedGuidedJournal: false,
                completionLevel: .seed
            )
        )
        XCTAssertNil(outcome)
    }

    func test_postSeedJourneyOutcome_whenUITests_returnsNil() {
        let outcome = JournalTodayOrientationPolicy.postSeedJourneyOutcome(
            for: .init(
                isTodayEntry: true,
                isRunningUITests: true,
                hasSeenPostSeedJourney: false,
                hasCompletedGuidedJournal: false,
                completionLevel: .seed
            )
        )
        XCTAssertNil(outcome)
    }

    func test_postSeedJourneyOutcome_delegatesToPostSeedTrigger_whenTodayAndNotUITests() {
        let expected = PostSeedJourneyTrigger.evaluate(
            hasSeenPostSeedJourney: false,
            hasCompletedGuidedJournal: true,
            todayCompletionLevel: .ripening
        )
        let actual = JournalTodayOrientationPolicy.postSeedJourneyOutcome(
            for: .init(
                isTodayEntry: true,
                isRunningUITests: false,
                hasSeenPostSeedJourney: false,
                hasCompletedGuidedJournal: true,
                completionLevel: .ripening
            )
        )
        XCTAssertEqual(actual?.skipsCongratulationsPage, expected?.skipsCongratulationsPage)
    }

    // MARK: - shouldSuppressSeedUnlockToast

    func test_shouldSuppressSeedUnlockToast_todayAtSeed_notSeenPostSeed_suppresses() {
        XCTAssertTrue(
            JournalTodayOrientationPolicy.shouldSuppressSeedUnlockToast(
                isTodayEntry: true,
                newLevel: .seed,
                hasSeenPostSeedJourney: false
            )
        )
    }

    func test_shouldSuppressSeedUnlockToast_notToday_doesNotSuppress() {
        XCTAssertFalse(
            JournalTodayOrientationPolicy.shouldSuppressSeedUnlockToast(
                isTodayEntry: false,
                newLevel: .seed,
                hasSeenPostSeedJourney: false
            )
        )
    }

    func test_shouldSuppressSeedUnlockToast_nonSeedLevel_doesNotSuppress() {
        XCTAssertFalse(
            JournalTodayOrientationPolicy.shouldSuppressSeedUnlockToast(
                isTodayEntry: true,
                newLevel: .ripening,
                hasSeenPostSeedJourney: false
            )
        )
    }

    func test_shouldSuppressSeedUnlockToast_alreadySeenPostSeed_doesNotSuppress() {
        XCTAssertFalse(
            JournalTodayOrientationPolicy.shouldSuppressSeedUnlockToast(
                isTodayEntry: true,
                newLevel: .seed,
                hasSeenPostSeedJourney: true
            )
        )
    }
}
