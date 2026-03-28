import XCTest
@testable import GraceNotes

final class ReviewRhythmFormattingTests: XCTestCase {
    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.locale = Locale(identifier: "en_US_POSIX")
    }

    func test_dayLabel_dateInsideWeek_usesAbbreviatedWeekday() {
        let weekStart = date(year: 2026, month: 3, day: 21)
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
        let midWeek = date(year: 2026, month: 3, day: 24)

        let label = ReviewRhythmFormatting.dayLabel(
            date: midWeek,
            currentWeek: weekStart..<weekEnd,
            calendar: calendar,
            now: date(year: 2020, month: 1, day: 1)
        )

        XCTAssertFalse(
            label.contains("/"),
            "Weekday-in-week label should not use M/d numeric form; got \(label)"
        )
        XCTAssertFalse(label.isEmpty)
        XCTAssertNotEqual(
            label,
            String(localized: "Today"),
            "With a non-today reference date, label should be a weekday, not the localized Today string; got \(label)"
        )
    }

    func test_dayLabel_dateInsideWeek_matchingNow_usesToday() {
        let weekStart = date(year: 2026, month: 3, day: 21)
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
        let todayInWeek = date(year: 2026, month: 3, day: 24)

        let label = ReviewRhythmFormatting.dayLabel(
            date: todayInWeek,
            currentWeek: weekStart..<weekEnd,
            calendar: calendar,
            now: todayInWeek
        )

        XCTAssertEqual(label, String(localized: "Today"))
    }

    func test_dayLabel_dateOutsideWeek_usesMonthDayDigits() {
        let weekStart = date(year: 2026, month: 3, day: 21)
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
        let beforeWeek = date(year: 2026, month: 3, day: 14)

        let label = ReviewRhythmFormatting.dayLabel(
            date: beforeWeek,
            currentWeek: weekStart..<weekEnd,
            calendar: calendar
        )

        XCTAssertTrue(
            label.rangeOfCharacter(from: .decimalDigits) != nil,
            "Expected date label to contain at least one digit, got: \(label)"
        )
        let shortWeekdaySymbols = Set(calendar.shortWeekdaySymbols)
        XCTAssertFalse(
            shortWeekdaySymbols.contains(label),
            "Expected date label to be a numeric style, not just a weekday name; got: \(label)"
        )
    }

    func test_assetName_mapsAllCompletionLevels() {
        XCTAssertEqual(ReviewRhythmFormatting.assetName(for: .empty), "empty")
        XCTAssertEqual(ReviewRhythmFormatting.assetName(for: .started), "started")
        XCTAssertEqual(ReviewRhythmFormatting.assetName(for: .growing), "growing")
        XCTAssertEqual(ReviewRhythmFormatting.assetName(for: .balanced), "balanced")
        XCTAssertEqual(ReviewRhythmFormatting.assetName(for: .full), "full")
    }

    private func date(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return calendar.date(from: components)!
    }
}
