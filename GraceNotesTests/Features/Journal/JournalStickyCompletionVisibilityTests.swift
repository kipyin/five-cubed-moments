import XCTest
@testable import GraceNotes

final class JournalStickyCompletionVisibilityTests: XCTestCase {
    func test_barIndicatorHidden_whenHeaderStillBelowNavRegion() {
        XCTAssertFalse(
            JournalStickyCompletionVisibility.shouldShowBarIndicator(
                completionHeaderTopGlobalY: 280,
                safeAreaTopInset: 59,
                headerTopPastToolbarSlackPoints: 96
            )
        )
    }

    func test_barIndicatorVisible_whenHeaderMovesIntoNavRegion() {
        XCTAssertTrue(
            JournalStickyCompletionVisibility.shouldShowBarIndicator(
                completionHeaderTopGlobalY: 120,
                safeAreaTopInset: 59,
                headerTopPastToolbarSlackPoints: 96
            )
        )
    }
}
