import XCTest
@testable import GraceNotes

@MainActor
final class SentenceStripViewTests: XCTestCase {
    func test_requiresExpandedPreview_returnsFalseForShortSentence() {
        XCTAssertFalse(SentenceStripView.requiresExpandedPreview("Short reflection."))
    }

    func test_requiresExpandedPreview_returnsTrueForLongSentence() {
        let sentence = "I am grateful for a long and thoughtful conversation that helped me process the day with calm."
        XCTAssertTrue(SentenceStripView.requiresExpandedPreview(sentence))
    }
}
