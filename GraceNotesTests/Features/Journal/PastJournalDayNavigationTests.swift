import XCTest
@testable import GraceNotes

final class PastJournalDayNavigationTests: XCTestCase {
    private var calendar: Calendar!

    override func setUpWithError() throws {
        try super.setUpWithError()
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar = cal
    }

    func test_sortedDistinctDayStarts_dedupesAndSortsAscending() {
        let dayA = calendar.startOfDay(for: Date(timeIntervalSince1970: 1_742_056_800)) // 2025-03-04
        let dayB = calendar.startOfDay(for: Date(timeIntervalSince1970: 1_742_147_200)) // 2025-03-15

        let laterRow = Journal(entryDate: dayB, createdAt: dayB, updatedAt: dayB)
        let earlierRow = Journal(entryDate: dayA, createdAt: dayA, updatedAt: dayA)
        let duplicateLaterRow = Journal(entryDate: dayB, createdAt: dayB, updatedAt: dayB)

        let result = PastJournalDayNavigation.sortedDistinctDayStarts(
            from: [laterRow, earlierRow, duplicateLaterRow],
            calendar: calendar
        )

        XCTAssertEqual(result, [dayA, dayB])
    }

    func test_indexMatchingDay_findsIndex() {
        let dayA = calendar.startOfDay(for: Date(timeIntervalSince1970: 1_742_056_800))
        let dayB = calendar.startOfDay(for: Date(timeIntervalSince1970: 1_742_147_200))
        let sortedDays = [dayA, dayB]

        XCTAssertEqual(
            PastJournalDayNavigation.indexMatchingDay(dayStart: dayB, in: sortedDays, calendar: calendar),
            1
        )
        XCTAssertNil(
            PastJournalDayNavigation.indexMatchingDay(
                dayStart: calendar.date(byAdding: .day, value: 7, to: dayB)!,
                in: sortedDays,
                calendar: calendar
            )
        )
    }
}
