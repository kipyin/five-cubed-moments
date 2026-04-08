import XCTest
@testable import GraceNotes

final class JournalStickyCompletionVisibilityTests: XCTestCase {
    /// Mirrors `JournalScreenLayout.stickyCompletionBarScrollRevealPoints` (iOS 17 scroll-space path).
    private let threshold: CGFloat = 0

    // MARK: - iOS 17 header minY in scroll space

    func test_barIndicatorHidden_whenHeaderMinYAtZero() {
        XCTAssertFalse(
            JournalStickyCompletionVisibility.shouldShowBarIndicator(
                headerMinYInScrollSpace: 0,
                scrollRevealThreshold: threshold
            )
        )
    }

    func test_barIndicatorVisible_whenHeaderMinYNegative() {
        XCTAssertTrue(
            JournalStickyCompletionVisibility.shouldShowBarIndicator(
                headerMinYInScrollSpace: -4,
                scrollRevealThreshold: threshold
            )
        )
    }

    // MARK: - iOS 18+ scroll content offset

    func test_barIndicatorHidden_whenScrollOffsetAtZero() {
        XCTAssertFalse(
            JournalStickyCompletionVisibility.shouldShowBarIndicator(
                scrollContentOffsetY: 0,
                scrollRevealThreshold: threshold
            )
        )
    }

    func test_barIndicatorVisible_whenScrollOffsetPositive() {
        XCTAssertTrue(
            JournalStickyCompletionVisibility.shouldShowBarIndicator(
                scrollContentOffsetY: 4,
                scrollRevealThreshold: threshold
            )
        )
    }

    func test_barIndicator_respectsNonZeroThreshold_forContentOffset() {
        XCTAssertFalse(
            JournalStickyCompletionVisibility.shouldShowBarIndicator(
                scrollContentOffsetY: 2,
                scrollRevealThreshold: 4
            )
        )
        XCTAssertTrue(
            JournalStickyCompletionVisibility.shouldShowBarIndicator(
                scrollContentOffsetY: 5,
                scrollRevealThreshold: 4
            )
        )
    }

    func test_barIndicator_respectsNonZeroThreshold_forHeaderMinY() {
        XCTAssertFalse(
            JournalStickyCompletionVisibility.shouldShowBarIndicator(
                headerMinYInScrollSpace: -2,
                scrollRevealThreshold: 4
            )
        )
        XCTAssertTrue(
            JournalStickyCompletionVisibility.shouldShowBarIndicator(
                headerMinYInScrollSpace: -5,
                scrollRevealThreshold: 4
            )
        )
    }
}
