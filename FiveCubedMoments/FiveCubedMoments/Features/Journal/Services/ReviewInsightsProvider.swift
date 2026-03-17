import Foundation

struct ReviewInsightsProvider: Sendable {
    static let useAIReviewInsightsKey = "useAIReviewInsights"
    private static let placeholderApiKey = "YOUR_KEY_HERE"

    private let deterministicGenerator: any ReviewInsightsGenerating
    private let cloudGenerator: (any ReviewInsightsGenerating)?

    init(
        deterministicGenerator: any ReviewInsightsGenerating = DeterministicReviewInsightsGenerator(),
        cloudGenerator: (any ReviewInsightsGenerating)? = nil,
        apiKey: String = ApiSecrets.cloudApiKey
    ) {
        self.deterministicGenerator = deterministicGenerator

        if let cloudGenerator {
            self.cloudGenerator = cloudGenerator
        } else if apiKey != Self.placeholderApiKey {
            self.cloudGenerator = CloudReviewInsightsGenerator(apiKey: apiKey)
        } else {
            self.cloudGenerator = nil
        }
    }

    func generateInsights(
        from entries: [JournalEntry],
        referenceDate: Date,
        calendar: Calendar = .current
    ) async -> ReviewInsights {
        let useAI = UserDefaults.standard.bool(forKey: Self.useAIReviewInsightsKey)

        if useAI, let cloudGenerator {
            if let cloudInsights = try? await cloudGenerator.generateInsights(
                from: entries,
                referenceDate: referenceDate,
                calendar: calendar
            ) {
                return cloudInsights
            }
        }

        if let deterministicInsights = try? await deterministicGenerator.generateInsights(
            from: entries,
            referenceDate: referenceDate,
            calendar: calendar
        ) {
            return deterministicInsights
        }

        return ReviewInsights(
            source: .deterministic,
            generatedAt: referenceDate,
            weekStart: calendar.startOfDay(for: referenceDate),
            weekEnd: calendar.date(byAdding: .day, value: 7, to: calendar.startOfDay(for: referenceDate))
                ?? referenceDate,
            recurringGratitudes: [],
            recurringNeeds: [],
            recurringPeople: [],
            resurfacingMessage: "Start with one reflection today to build your weekly review.",
            continuityPrompt: "What feels most important to carry into next week?",
            narrativeSummary: nil
        )
    }

    nonisolated(unsafe) static let shared = ReviewInsightsProvider()
}
