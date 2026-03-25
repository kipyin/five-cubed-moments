import XCTest
@testable import GraceNotes

final class ReviewInsightsCacheTests: XCTestCase {
    private var calendar: Calendar!
    private var userDefaults: UserDefaults!
    private var cache: ReviewInsightsCache!

    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let suiteName = "ReviewInsightsCacheTests.\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)
        cache = ReviewInsightsCache(userDefaults: userDefaults)
    }

    func test_storeAndLoad_roundTripsForMatchingWeek() {
        let weekStart = date(year: 2026, month: 3, day: 12)
        let insights = sampleInsights(weekStart: weekStart)

        cache.storeIfEligible(insights, calendar: calendar)
        let loaded = cache.insights(forWeekStart: weekStart, calendar: calendar)

        XCTAssertEqual(loaded, insights)
    }

    func test_store_skipsSparseProviderFallback() {
        let weekStart = date(year: 2026, month: 3, day: 12)
        let sparse = sparseFallbackInsights(weekStart: weekStart)

        cache.storeIfEligible(sparse, calendar: calendar)
        let loaded = cache.insights(forWeekStart: weekStart, calendar: calendar)

        XCTAssertNil(loaded)
    }

    func test_JSONEncoder_roundTripReviewInsights() throws {
        let insights = sampleInsights(weekStart: date(year: 2026, month: 3, day: 12))
        let data = try JSONEncoder().encode(insights)
        let decoded = try JSONDecoder().decode(ReviewInsights.self, from: data)
        XCTAssertEqual(decoded, insights)
    }

    // MARK: - Helpers

    private func date(year: Int, month: Int, day: Int) -> Date {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        return calendar.date(from: comps)!
    }

    private func sampleInsights(weekStart: Date) -> ReviewInsights {
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
        return ReviewInsights(
            source: .deterministic,
            generatedAt: weekStart,
            weekStart: weekStart,
            weekEnd: weekEnd,
            weeklyInsights: [
                ReviewWeeklyInsight(
                    pattern: .recurringTheme,
                    observation: "You wrote about calm several times.",
                    action: "Notice when calm shows up again.",
                    primaryTheme: "calm",
                    mentionCount: 3,
                    dayCount: 2
                )
            ],
            recurringGratitudes: [ReviewInsightTheme(label: "Walks", count: 2)],
            recurringNeeds: [],
            recurringPeople: [],
            resurfacingMessage: "A thread from your week.",
            continuityPrompt: "One small next step.",
            narrativeSummary: "A gentle arc."
        )
    }

    private func sparseFallbackInsights(weekStart: Date) -> ReviewInsights {
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
        return ReviewInsights(
            source: .deterministic,
            generatedAt: weekStart,
            weekStart: weekStart,
            weekEnd: weekEnd,
            weeklyInsights: [
                ReviewWeeklyInsight(
                    pattern: .sparseFallback,
                    observation: "Keep going.",
                    action: nil,
                    primaryTheme: nil,
                    mentionCount: nil,
                    dayCount: 0
                )
            ],
            recurringGratitudes: [],
            recurringNeeds: [],
            recurringPeople: [],
            resurfacingMessage: "",
            continuityPrompt: "",
            narrativeSummary: nil
        )
    }
}
