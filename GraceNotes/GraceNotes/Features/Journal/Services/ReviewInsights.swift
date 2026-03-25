import Foundation

enum ReviewInsightSource: String, Sendable, Codable {
    case deterministic
    case cloudAI
}

/// Set when the user enabled Cloud AI but this digest still used the on-device path (see issue #83).
enum ReviewCloudInsightSkipReason: String, Equatable, Sendable, Codable {
    /// Fewer than the minimum meaningful reflections for cloud generation this review week.
    case insufficientEvidenceThisWeek
    /// No cloud generator (for example, missing API key in this build).
    case cloudMisconfigured
    /// Cloud generation was attempted but did not return a usable digest.
    case cloudGenerationFailed
}

extension ReviewCloudInsightSkipReason {
    // Long user-facing sentences; keys match `Localizable.xcstrings`.
    // swiftlint:disable line_length
    /// Short explanation for the review-source info affordance.
    var localizedExplanation: String {
        switch self {
        case .insufficientEvidenceThisWeek:
            String(
                localized: "Cloud insights need at least three meaningful reflections in this review week. With lighter weeks, Grace Notes keeps this digest on your device."
            )
        case .cloudMisconfigured:
            String(
                localized: "Cloud AI isn't available in this build (for example, no API key). This digest stayed on your device."
            )
        case .cloudGenerationFailed:
            String(
                localized: "Cloud AI couldn't finish this digest (network or quality checks). Grace Notes used your on-device summary instead."
            )
        }
    }

    // swiftlint:enable line_length
}

enum ReviewWeeklyInsightPattern: String, Sendable, Codable {
    case recurringPeople
    case recurringTheme
    case needsGratitudeGap
    case fullCompletion
    case continuityShift
    case sparseFallback
}

struct ReviewWeeklyInsight: Equatable, Hashable, Sendable, Codable {
    let pattern: ReviewWeeklyInsightPattern
    let observation: String
    let action: String?
    let primaryTheme: String?
    let mentionCount: Int?
    let dayCount: Int?
}

struct ReviewInsightTheme: Equatable, Hashable, Sendable, Codable {
    let label: String
    let count: Int
}

struct ReviewInsights: Equatable, Sendable, Codable {
    let source: ReviewInsightSource
    let generatedAt: Date
    /// Start of the review period (`ReviewInsightsPeriod`), inclusive (start of local day).
    let weekStart: Date
    /// End of the review period, exclusive (start of the day after the reference day).
    let weekEnd: Date
    let weeklyInsights: [ReviewWeeklyInsight]
    let recurringGratitudes: [ReviewInsightTheme]
    let recurringNeeds: [ReviewInsightTheme]
    let recurringPeople: [ReviewInsightTheme]
    let resurfacingMessage: String
    let continuityPrompt: String
    let narrativeSummary: String?
    /// Present when Cloud AI was enabled at generation time but the digest used the on-device path.
    let cloudSkippedReason: ReviewCloudInsightSkipReason?
}

extension ReviewInsights {
    func withCloudSkippedReason(_ reason: ReviewCloudInsightSkipReason?) -> ReviewInsights {
        ReviewInsights(
            source: source,
            generatedAt: generatedAt,
            weekStart: weekStart,
            weekEnd: weekEnd,
            weeklyInsights: weeklyInsights,
            recurringGratitudes: recurringGratitudes,
            recurringNeeds: recurringNeeds,
            recurringPeople: recurringPeople,
            resurfacingMessage: resurfacingMessage,
            continuityPrompt: continuityPrompt,
            narrativeSummary: narrativeSummary,
            cloudSkippedReason: reason
        )
    }
}

protocol ReviewInsightsGenerating: Sendable {
    func generateInsights(
        from entries: [JournalEntry],
        referenceDate: Date,
        calendar: Calendar
    ) async throws -> ReviewInsights
}
