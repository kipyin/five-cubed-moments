import XCTest
@testable import GraceNotes

final class JournalStickyCompletionVisibilityTests: XCTestCase {
    func test_barIndicatorHidden_whileNearTopOfContent() {
        XCTAssertFalse(
            JournalStickyCompletionVisibility.shouldShowBarIndicator(
                scrollContentMinY: 0,
                hideUntilScrolledPast: 88
            )
        )
        XCTAssertFalse(
            JournalStickyCompletionVisibility.shouldShowBarIndicator(
                scrollContentMinY: -40,
                hideUntilScrolledPast: 88
            )
        )
    }

    func test_barIndicatorVisible_afterScrollingPastThreshold() {
        XCTAssertTrue(
            JournalStickyCompletionVisibility.shouldShowBarIndicator(
                scrollContentMinY: -120,
                hideUntilScrolledPast: 88
            )
        )
    }
}
