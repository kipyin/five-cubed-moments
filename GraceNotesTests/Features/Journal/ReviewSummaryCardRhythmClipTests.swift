import XCTest
@testable import GraceNotes

final class ReviewSummaryCardRhythmClipTests: XCTestCase {
    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 1
    }

    func test_rollingRhythmDaysForDisplay_emitsSevenDaysEndingOnReference() {
        let reference = date(year: 2026, month: 3, day: 18)
        let strayWeekStart = date(year: 2026, month: 2, day: 1)
        let rawDays = (0..<7).map { offset -> ReviewDayActivity in
            let day = calendar.date(byAdding: .day, value: offset, to: strayWeekStart)!
            return ReviewDayActivity(date: day, hasReflectiveActivity: true, hasPersistedEntry: true)
        }
        let (days, interval) = ReviewDaysYouWrotePanel.rollingRhythmDaysForDisplay(
            rawDays,
            referenceNow: reference,
            calendar: calendar
        )
        XCTAssertEqual(days.count, 7)
        XCTAssertEqual(calendar.startOfDay(for: days.last!.date), calendar.startOfDay(for: reference))
        let expectedStart = calendar.startOfDay(
            for: calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: reference))!
        )
        XCTAssertEqual(calendar.startOfDay(for: days.first!.date), expectedStart)
        XCTAssertTrue(interval.contains(expectedStart))
        XCTAssertTrue(interval.contains(calendar.startOfDay(for: reference)))
    }

    func test_rollingRhythmDaysForDisplay_fillsGapsWithEmptyColumns() {
        let reference = date(year: 2026, month: 3, day: 18)
        let penultimate = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: reference))!
        let raw = [
            ReviewDayActivity(date: penultimate, hasReflectiveActivity: true, hasPersistedEntry: true)
        ]
        let (days, _) = ReviewDaysYouWrotePanel.rollingRhythmDaysForDisplay(
            raw,
            referenceNow: reference,
            calendar: calendar
        )
        XCTAssertEqual(days.count, 7)
        let emptyColumns = days.filter { !$0.hasPersistedEntry }
        XCTAssertFalse(emptyColumns.isEmpty)
        let filled = days.first { calendar.isDate($0.date, inSameDayAs: penultimate) }
        XCTAssertEqual(filled?.hasPersistedEntry, true)
    }

    private func date(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.timeZone = calendar.timeZone
        return calendar.date(from: components)!
    }
}
