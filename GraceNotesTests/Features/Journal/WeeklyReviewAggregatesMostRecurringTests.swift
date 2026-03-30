import XCTest
@testable import GraceNotes

final class WeeklyReviewAggregatesMostRecurringTests: XCTestCase {
    private var calendar: Calendar!
    private var builder: WeeklyReviewAggregatesBuilder!

    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 1 // Sunday
        builder = WeeklyReviewAggregatesBuilder()
    }

    func test_buildThemeSections_mostRecurringUsesRollingWindowAndMinimumSignals() throws {
        let referenceDate = date(year: 2026, month: 3, day: 18)
        let period = ReviewInsightsPeriod.currentPeriod(containing: referenceDate, calendar: calendar)
        let previous = ReviewInsightsPeriod.previousPeriod(before: period, calendar: calendar)

        let insideWindow = [
            makeEntry(on: date(year: 2026, month: 3, day: 3), needs: ["quiet morning"]),
            makeEntry(on: date(year: 2026, month: 3, day: 10), needs: ["quiet morning"]),
            makeEntry(on: date(year: 2026, month: 3, day: 17), needs: ["quiet morning"]),
            makeEntry(on: date(year: 2026, month: 3, day: 17), needs: ["therapy"])
        ]
        let outsideWindow = [
            makeEntry(on: date(year: 2026, month: 2, day: 1), needs: ["quiet morning"])
        ]

        let aggregates = builder.build(
            currentPeriod: period,
            currentWeekEntries: insideWindow.filter { period.contains($0.entryDate) },
            previousWeekEntries: insideWindow.filter { previous.contains($0.entryDate) },
            allEntries: outsideWindow + insideWindow,
            calendar: calendar
        )

        let recurring = aggregates.stats.mostRecurringThemes
        let quiet = try XCTUnwrap(recurring.first(where: { $0.label == "Quiet time" }))
        XCTAssertEqual(quiet.totalCount, 3, "Only entries from the rolling 4-week window should be counted.")
        XCTAssertFalse(recurring.contains(where: { $0.label == "Therapy" }))
    }

    func test_buildThemeSections_appliesGlobalAliasesAndCrossLanguageMerges() throws {
        let referenceDate = date(year: 2026, month: 3, day: 18)
        let period = ReviewInsightsPeriod.currentPeriod(containing: referenceDate, calendar: calendar)
        let previous = ReviewInsightsPeriod.previousPeriod(before: period, calendar: calendar)

        let entries = [
            makeEntry(on: date(year: 2026, month: 3, day: 16), needs: ["Rest"]),
            makeEntry(on: date(year: 2026, month: 3, day: 17), needs: ["recover"]),
            makeEntry(on: date(year: 2026, month: 3, day: 18), needs: ["休息"])
        ]
        let aggregates = builder.build(
            currentPeriod: period,
            currentWeekEntries: entries.filter { period.contains($0.entryDate) },
            previousWeekEntries: entries.filter { previous.contains($0.entryDate) },
            allEntries: entries,
            calendar: calendar
        )

        let restTheme = try XCTUnwrap(aggregates.stats.mostRecurringThemes.first(where: { $0.label == "Rest" }))
        XCTAssertEqual(restTheme.totalCount, 3)
    }

    func test_buildThemeSections_peopleRemainLiteralWithLightNormalization() throws {
        let referenceDate = date(year: 2026, month: 3, day: 18)
        let period = ReviewInsightsPeriod.currentPeriod(containing: referenceDate, calendar: calendar)
        let previous = ReviewInsightsPeriod.previousPeriod(before: period, calendar: calendar)

        let entries = [
            makeEntry(on: date(year: 2026, month: 3, day: 16), people: ["MIA"]),
            makeEntry(on: date(year: 2026, month: 3, day: 17), people: ["mia"]),
            makeEntry(on: date(year: 2026, month: 3, day: 18), people: [" Mia "])
        ]
        let aggregates = builder.build(
            currentPeriod: period,
            currentWeekEntries: entries.filter { period.contains($0.entryDate) },
            previousWeekEntries: entries.filter { previous.contains($0.entryDate) },
            allEntries: entries,
            calendar: calendar
        )

        let literal = try XCTUnwrap(aggregates.stats.mostRecurringThemes.first(where: { $0.label == "Mia" }))
        XCTAssertEqual(literal.totalCount, 3)
    }

    func test_buildThemeSections_trendingIncludesNewUpAndDownWithPriorVsCurrentCounts() throws {
        let referenceDate = date(year: 2026, month: 3, day: 18)
        let period = ReviewInsightsPeriod.currentPeriod(containing: referenceDate, calendar: calendar)
        let previous = ReviewInsightsPeriod.previousPeriod(before: period, calendar: calendar)

        let entries = [
            // up: current 2, previous 1
            makeEntry(on: date(year: 2026, month: 3, day: 9), needs: ["rest"]),
            makeEntry(on: date(year: 2026, month: 3, day: 16), needs: ["rest"]),
            makeEntry(on: date(year: 2026, month: 3, day: 17), needs: ["rest"]),

            // down: current 1, previous 2
            makeEntry(on: date(year: 2026, month: 3, day: 9), gratitudes: ["walking"]),
            makeEntry(on: date(year: 2026, month: 3, day: 10), gratitudes: ["walking"]),
            makeEntry(on: date(year: 2026, month: 3, day: 16), gratitudes: ["walking"]),

            // new: current 1, previous 0
            makeEntry(on: date(year: 2026, month: 3, day: 16), gratitudes: ["therapy"]),

            // stable: should not surface in trending
            makeEntry(on: date(year: 2026, month: 3, day: 9), needs: ["focus"]),
            makeEntry(on: date(year: 2026, month: 3, day: 16), needs: ["focus"])
        ]

        let stats = builder.build(
            currentPeriod: period,
            currentWeekEntries: entries.filter { period.contains($0.entryDate) },
            previousWeekEntries: entries.filter { previous.contains($0.entryDate) },
            allEntries: entries,
            calendar: calendar
        ).stats
        let trending = stats.movementThemes
        let buckets = stats.trendingBuckets

        let rest = try XCTUnwrap(trending.first(where: { $0.label == "Rest" }))
        XCTAssertEqual(rest.trend, .rising)
        XCTAssertEqual(rest.previousWeekCount, 1)
        XCTAssertEqual(rest.currentWeekCount, 2)

        let walking = try XCTUnwrap(trending.first(where: { $0.label == "Walking" }))
        XCTAssertEqual(walking.trend, .down)
        XCTAssertEqual(walking.previousWeekCount, 2)
        XCTAssertEqual(walking.currentWeekCount, 1)

        let therapy = try XCTUnwrap(trending.first(where: { $0.label == "Therapy" }))
        XCTAssertEqual(therapy.trend, .new)
        XCTAssertEqual(therapy.previousWeekCount, 0)
        XCTAssertEqual(therapy.currentWeekCount, 1)

        XCTAssertNil(trending.first(where: { $0.label == "Focus" }))

        XCTAssertEqual(buckets.newThemes.map(\.label), ["Therapy"])
        XCTAssertEqual(buckets.upThemes.map(\.label), ["Rest"])
        XCTAssertEqual(buckets.downThemes.map(\.label), ["Walking"])
        XCTAssertEqual(trending, buckets.flattened)
    }

    func test_trendingUsesRollingSevenDayWindowsComparedToPriorSevenDays() throws {
        let referenceDate = date(year: 2026, month: 3, day: 18)
        let period = ReviewInsightsPeriod.currentPeriod(containing: referenceDate, calendar: calendar)
        let previous = ReviewInsightsPeriod.previousPeriod(before: period, calendar: calendar)

        // Mar 12 is the first day of the rolling window ending Mar 18; it sits outside a Sun-start
        // calendar "current" week that begins Mar 15, so rolling vs calendar-week trending would disagree.
        let entries = [
            makeEntry(on: date(year: 2026, month: 3, day: 12), needs: ["therapy"])
        ]

        let stats = builder.build(
            currentPeriod: period,
            currentWeekEntries: entries.filter { period.contains($0.entryDate) },
            previousWeekEntries: entries.filter { previous.contains($0.entryDate) },
            allEntries: entries,
            calendar: calendar
        ).stats

        let therapy = try XCTUnwrap(stats.trendingBuckets.newThemes.first(where: { $0.label == "Therapy" }))
        XCTAssertEqual(therapy.trend, .new)
        XCTAssertEqual(therapy.previousWeekCount, 0)
        XCTAssertEqual(therapy.currentWeekCount, 1)
        XCTAssertEqual(stats.trendingBuckets.newThemes.map(\.label), ["Therapy"])
        XCTAssertTrue(stats.trendingBuckets.upThemes.isEmpty)
        XCTAssertTrue(stats.trendingBuckets.downThemes.isEmpty)
    }

    func test_buildThemeSections_countsEachStructuredSurfaceOnceEqualWeight() throws {
        let referenceDate = date(year: 2026, month: 3, day: 18)
        let period = ReviewInsightsPeriod.currentPeriod(containing: referenceDate, calendar: calendar)
        let previous = ReviewInsightsPeriod.previousPeriod(before: period, calendar: calendar)

        let entries = [
            makeEntry(
                on: date(year: 2026, month: 3, day: 17),
                gratitudes: ["rest"],
                needs: ["recover"]
            )
        ]
        let aggregates = builder.build(
            currentPeriod: period,
            currentWeekEntries: entries.filter { period.contains($0.entryDate) },
            previousWeekEntries: entries.filter { previous.contains($0.entryDate) },
            allEntries: entries,
            calendar: calendar
        )
        let rest = try XCTUnwrap(aggregates.stats.mostRecurringThemes.first(where: { $0.label == "Rest" }))
        XCTAssertEqual(
            rest.totalCount,
            2,
            "Gratitudes and needs are separate surfaces; each counts once when they match."
        )
    }

    func test_buildThemeSections_hardBannedConceptsNeverSurface() {
        let referenceDate = date(year: 2026, month: 3, day: 18)
        let period = ReviewInsightsPeriod.currentPeriod(containing: referenceDate, calendar: calendar)
        let previous = ReviewInsightsPeriod.previousPeriod(before: period, calendar: calendar)

        let entries = [
            makeEntry(on: date(year: 2026, month: 3, day: 16), needs: ["reflection"]),
            makeEntry(on: date(year: 2026, month: 3, day: 17), gratitudes: ["journal"]),
            makeEntry(on: date(year: 2026, month: 3, day: 18), needs: ["things"]),
            makeEntry(on: date(year: 2026, month: 3, day: 16), needs: ["rest"]),
            makeEntry(on: date(year: 2026, month: 3, day: 17), needs: ["rest"])
        ]
        let recurring = builder.build(
            currentPeriod: period,
            currentWeekEntries: entries.filter { period.contains($0.entryDate) },
            previousWeekEntries: entries.filter { previous.contains($0.entryDate) },
            allEntries: entries,
            calendar: calendar
        ).stats.mostRecurringThemes

        XCTAssertTrue(recurring.contains(where: { $0.label == "Rest" }))
        let bannedLabels: Set<String> = ["Reflection", "Journal", "Things"]
        XCTAssertTrue(recurring.allSatisfy { !bannedLabels.contains($0.label) })
    }

    func test_buildThemeSections_penalizedGenericWorkOmittedWithoutStrongContext() {
        let referenceDate = date(year: 2026, month: 3, day: 18)
        let period = ReviewInsightsPeriod.currentPeriod(containing: referenceDate, calendar: calendar)
        let previous = ReviewInsightsPeriod.previousPeriod(before: period, calendar: calendar)

        let entries = [
            makeEntry(on: date(year: 2026, month: 3, day: 16), needs: ["work"]),
            makeEntry(on: date(year: 2026, month: 3, day: 17), needs: ["work"])
        ]
        let recurring = builder.build(
            currentPeriod: period,
            currentWeekEntries: entries.filter { period.contains($0.entryDate) },
            previousWeekEntries: entries.filter { previous.contains($0.entryDate) },
            allEntries: entries,
            calendar: calendar
        ).stats.mostRecurringThemes

        XCTAssertFalse(recurring.contains(where: { $0.label == "Work" }))
    }

    func test_mostRecurringBrowseWindow_keepsPeopleEvidenceAlignedWithReviewCalendar() throws {
        let referenceDate = date(year: 2026, month: 3, day: 30)
        let period = ReviewInsightsPeriod.currentPeriod(containing: referenceDate, calendar: calendar)
        let previous = ReviewInsightsPeriod.previousPeriod(before: period, calendar: calendar)
        let refDay = calendar.startOfDay(for: referenceDate)

        var entries: [JournalEntry] = []
        for dayOffset in 1...22 {
            let day = calendar.date(byAdding: .day, value: -dayOffset, to: refDay)!
            entries.append(makeEntry(on: day, gratitudes: ["rest"], needs: ["focus"], people: ["Dad"]))
        }

        let stats = builder.build(
            currentPeriod: period,
            currentWeekEntries: entries.filter { period.contains($0.entryDate) },
            previousWeekEntries: entries.filter { previous.contains($0.entryDate) },
            allEntries: entries,
            calendar: calendar
        ).stats

        let dad = try XCTUnwrap(stats.mostRecurringThemes.first(where: { $0.label == "Dad" }))
        XCTAssertTrue(dad.evidence.contains { $0.source == .people })

        let reviewWeekEnd = period.upperBound
        let daysBack = 28
        let rawLower = calendar.date(byAdding: .day, value: -daysBack, to: reviewWeekEnd)!
        let lowerBound = calendar.startOfDay(for: rawLower)
        let viewingRange = lowerBound..<reviewWeekEnd
        let windowedPeople = dad.evidence.filter { evidence in
            evidence.source == .people && viewingRange.contains(calendar.startOfDay(for: evidence.entryDate))
        }
        XCTAssertGreaterThan(
            windowedPeople.count,
            0,
            "Browse window filter should retain People in Mind evidence rows used in the sheet."
        )
    }

    func test_buildThemeSections_supportingEvidenceIncludesReadingAndReflectionsWithoutChangingCount() throws {
        let referenceDate = date(year: 2026, month: 3, day: 18)
        let period = ReviewInsightsPeriod.currentPeriod(containing: referenceDate, calendar: calendar)
        let previous = ReviewInsightsPeriod.previousPeriod(before: period, calendar: calendar)

        let entries = [
            makeEntry(
                on: date(year: 2026, month: 3, day: 16),
                needs: ["rest"],
                readingNotes: "I am practicing deeper rest this week."
            ),
            makeEntry(
                on: date(year: 2026, month: 3, day: 17),
                needs: ["rest"],
                reflections: "Rest helped me recover today."
            ),
            makeEntry(
                on: date(year: 2026, month: 3, day: 18),
                readingNotes: "Movement matters.",
                reflections: "Only long-form notes, no structured line."
            )
        ]

        let recurring = builder.build(
            currentPeriod: period,
            currentWeekEntries: entries.filter { period.contains($0.entryDate) },
            previousWeekEntries: entries.filter { previous.contains($0.entryDate) },
            allEntries: entries,
            calendar: calendar
        ).stats.mostRecurringThemes

        let rest = try XCTUnwrap(recurring.first(where: { $0.label == "Rest" }))
        XCTAssertEqual(rest.totalCount, 2, "Reading/reflection evidence should not inflate count totals.")
        XCTAssertTrue(rest.evidence.contains(where: { $0.source == .readingNotes }))
        XCTAssertTrue(rest.evidence.contains(where: { $0.source == .reflections }))
        XCTAssertFalse(recurring.contains(where: { $0.label == "Exercise" || $0.label == "Movement" }))
    }
}

private extension WeeklyReviewAggregatesMostRecurringTests {
    func makeEntry(
        on date: Date,
        gratitudes: [String] = [],
        needs: [String] = [],
        people: [String] = [],
        readingNotes: String = "",
        reflections: String = ""
    ) -> JournalEntry {
        JournalEntry(
            entryDate: date,
            gratitudes: gratitudes.map { JournalItem(fullText: $0, chipLabel: $0) },
            needs: needs.map { JournalItem(fullText: $0, chipLabel: $0) },
            people: people.map { JournalItem(fullText: $0, chipLabel: $0) },
            readingNotes: readingNotes,
            reflections: reflections
        )
    }

    func date(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.timeZone = calendar.timeZone
        return calendar.date(from: components)!
    }
}
