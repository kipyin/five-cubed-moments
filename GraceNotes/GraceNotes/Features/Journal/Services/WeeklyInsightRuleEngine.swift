import Foundation

struct WeeklyInsightAnalysis {
    let weeklyInsights: [ReviewWeeklyInsight]
    let recurringGratitudes: [ReviewInsightTheme]
    let recurringNeeds: [ReviewInsightTheme]
    let recurringPeople: [ReviewInsightTheme]
    let narrativeSummary: String?
    let resurfacingMessage: String
    let continuityPrompt: String
    let weekStats: ReviewWeekStats
    let presentationMode: ReviewPresentationMode
}

struct WeeklyInsightRuleEngine {
    private let aggregatesBuilder = WeeklyReviewAggregatesBuilder()
    private let textNormalizer = WeeklyInsightTextNormalizer()

    // swiftlint:disable:next function_parameter_count
    func analyze(
        currentPeriod: Range<Date>,
        currentWeekEntries: [Journal],
        previousWeekEntries: [Journal],
        allEntries: [Journal],
        calendar: Calendar,
        referenceDate: Date,
        pastStatisticsInterval: PastStatisticsIntervalSelection = .default
    ) -> WeeklyInsightAnalysis {
        let candidateBuilder = WeeklyInsightCandidateBuilder(textNormalizer: textNormalizer)
        let aggregates = aggregatesBuilder.build(
            currentPeriod: currentPeriod,
            currentWeekEntries: currentWeekEntries,
            previousWeekEntries: previousWeekEntries,
            allEntries: allEntries,
            calendar: calendar,
            referenceDate: referenceDate,
            pastStatisticsInterval: pastStatisticsInterval
        )

        let candidates = candidateBuilder.buildCandidates(inputs: aggregates.candidateInputs)

        let selectedInsights = candidateBuilder.selectInsights(
            from: candidates,
            fallback: candidateBuilder.fallbackInsight(
                reflectionDayCount: aggregates.candidateInputs.currentDayCount
            )
        )

        let normalizedInsights = Self.normalizedWeeklyInsights(selectedInsights)
        let narrativeSummary = candidateBuilder.narrativeSummary(from: normalizedInsights)
        let resurfacingMessage = Self.resurfacingMessage(
            for: normalizedInsights,
            emptyObservationFallback: String(localized: "review.insights.starterReflection")
        )
        let continuityPrompt = Self.continuityPrompt(
            for: normalizedInsights,
            defaultPrompt: candidateBuilder.defaultContinuityPrompt
        )

        return WeeklyInsightAnalysis(
            weeklyInsights: normalizedInsights,
            recurringGratitudes: aggregates.recurringGratitudes,
            recurringNeeds: aggregates.recurringNeeds,
            recurringPeople: aggregates.recurringPeople,
            narrativeSummary: narrativeSummary,
            resurfacingMessage: resurfacingMessage,
            continuityPrompt: continuityPrompt,
            weekStats: aggregates.stats,
            presentationMode: aggregates.supportsInsightNarrative ? .insight : .statsFirst
        )
    }
}

extension WeeklyInsightRuleEngine {
    /// Trims insight copy so `weeklyInsights` matches `resurfacingMessage` / `continuityPrompt`.
    static func normalizedWeeklyInsights(_ insights: [ReviewWeeklyInsight]) -> [ReviewWeeklyInsight] {
        insights.map { insight in
            let trimmedObservation = insight.observation.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedAction = insight.action?.trimmingCharacters(in: .whitespacesAndNewlines)
            let action: String? = {
                guard let trimmedAction, !trimmedAction.isEmpty else { return nil }
                return trimmedAction
            }()
            return ReviewWeeklyInsight(
                pattern: insight.pattern,
                observation: trimmedObservation,
                action: action,
                primaryTheme: insight.primaryTheme,
                mentionCount: insight.mentionCount,
                dayCount: insight.dayCount
            )
        }
    }

    static func resurfacingMessage(
        for insights: [ReviewWeeklyInsight],
        emptyObservationFallback: String
    ) -> String {
        guard let headline = insights.first?.observation, !headline.isEmpty else {
            return emptyObservationFallback
        }
        return headline
    }

    static func continuityPrompt(
        for insights: [ReviewWeeklyInsight],
        defaultPrompt: String
    ) -> String {
        insights.compactMap(\.action).first ?? defaultPrompt
    }
}
