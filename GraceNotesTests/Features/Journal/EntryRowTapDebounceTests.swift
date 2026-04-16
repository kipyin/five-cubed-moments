import XCTest
@testable import GraceNotes

final class EntryRowTapDebounceTests: XCTestCase {
    func test_acceptsFirstTap() {
        var lastID: UUID?
        var lastDate: Date?
        let id = UUID()
        let firstDate = Date(timeIntervalSince1970: 1_000)

        XCTAssertTrue(
            EntryRowTapDebounce.shouldProcessTap(
                itemID: id,
                at: firstDate,
                lastAcceptedItemID: &lastID,
                lastAcceptedDate: &lastDate,
                interval: EntryRowTapDebounce.sameRowTapDebounceInterval
            )
        )
        XCTAssertEqual(lastID, id)
        XCTAssertEqual(lastDate, firstDate)
    }

    func test_rejectsSecondTapOnSameRowWithinInterval() {
        var lastID: UUID?
        var lastDate: Date?
        let id = UUID()
        let firstDate = Date(timeIntervalSince1970: 1_000)
        let secondDate = firstDate.addingTimeInterval(0.1)

        XCTAssertTrue(
            EntryRowTapDebounce.shouldProcessTap(
                itemID: id,
                at: firstDate,
                lastAcceptedItemID: &lastID,
                lastAcceptedDate: &lastDate,
                interval: EntryRowTapDebounce.sameRowTapDebounceInterval
            )
        )
        XCTAssertFalse(
            EntryRowTapDebounce.shouldProcessTap(
                itemID: id,
                at: secondDate,
                lastAcceptedItemID: &lastID,
                lastAcceptedDate: &lastDate,
                interval: EntryRowTapDebounce.sameRowTapDebounceInterval
            )
        )
        XCTAssertEqual(lastID, id)
        XCTAssertEqual(lastDate, firstDate)
    }

    func test_acceptsSecondTapOnSameRowAfterInterval() {
        var lastID: UUID?
        var lastDate: Date?
        let id = UUID()
        let firstDate = Date(timeIntervalSince1970: 1_000)
        let secondDate = firstDate.addingTimeInterval(
            EntryRowTapDebounce.sameRowTapDebounceInterval + 0.05
        )

        XCTAssertTrue(
            EntryRowTapDebounce.shouldProcessTap(
                itemID: id,
                at: firstDate,
                lastAcceptedItemID: &lastID,
                lastAcceptedDate: &lastDate,
                interval: EntryRowTapDebounce.sameRowTapDebounceInterval
            )
        )
        XCTAssertTrue(
            EntryRowTapDebounce.shouldProcessTap(
                itemID: id,
                at: secondDate,
                lastAcceptedItemID: &lastID,
                lastAcceptedDate: &lastDate,
                interval: EntryRowTapDebounce.sameRowTapDebounceInterval
            )
        )
        XCTAssertEqual(lastID, id)
        XCTAssertEqual(lastDate, secondDate)
    }

    func test_acceptsTapOnDifferentRowImmediately() {
        var lastID: UUID?
        var lastDate: Date?
        let firstRowID = UUID()
        let secondRowID = UUID()
        let firstDate = Date(timeIntervalSince1970: 1_000)
        let secondDate = firstDate.addingTimeInterval(0.05)

        XCTAssertTrue(
            EntryRowTapDebounce.shouldProcessTap(
                itemID: firstRowID,
                at: firstDate,
                lastAcceptedItemID: &lastID,
                lastAcceptedDate: &lastDate,
                interval: EntryRowTapDebounce.sameRowTapDebounceInterval
            )
        )
        XCTAssertTrue(
            EntryRowTapDebounce.shouldProcessTap(
                itemID: secondRowID,
                at: secondDate,
                lastAcceptedItemID: &lastID,
                lastAcceptedDate: &lastDate,
                interval: EntryRowTapDebounce.sameRowTapDebounceInterval
            )
        )
        XCTAssertEqual(lastID, secondRowID)
        XCTAssertEqual(lastDate, secondDate)
    }

    /// If `at` moves backward (clock adjustment or test doubles), do not treat it as a rapid repeat.
    func test_acceptsTapWhenDateMovesBackward() {
        var lastID: UUID?
        var lastDate: Date?
        let id = UUID()
        let firstDate = Date(timeIntervalSince1970: 1_000)
        let earlierDate = firstDate.addingTimeInterval(-60)

        XCTAssertTrue(
            EntryRowTapDebounce.shouldProcessTap(
                itemID: id,
                at: firstDate,
                lastAcceptedItemID: &lastID,
                lastAcceptedDate: &lastDate,
                interval: EntryRowTapDebounce.sameRowTapDebounceInterval
            )
        )
        XCTAssertTrue(
            EntryRowTapDebounce.shouldProcessTap(
                itemID: id,
                at: earlierDate,
                lastAcceptedItemID: &lastID,
                lastAcceptedDate: &lastDate,
                interval: EntryRowTapDebounce.sameRowTapDebounceInterval
            )
        )
        XCTAssertEqual(lastID, id)
        XCTAssertEqual(lastDate, earlierDate)
    }
}
