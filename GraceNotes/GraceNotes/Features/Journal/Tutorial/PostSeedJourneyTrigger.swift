import Foundation

/// Pure policy for when the full-screen post-Seed orientation appears on Today (see `JournalScreen`).
enum PostSeedJourneyTrigger {
    struct Outcome {
        var skipsCongratulationsPage: Bool
    }

    /// - Returns: `nil` when the journey should not be presented.
    static func evaluate(
        hasSeenPostSeedJourney: Bool,
        pending051UpgradeOrientation: Bool,
        hasCompletedGuidedJournal: Bool,
        todayCompletionLevel: JournalCompletionLevel
    ) -> Outcome? {
        guard !hasSeenPostSeedJourney else { return nil }

        let seedRank = JournalCompletionLevel.seed.tutorialCompletionRank
        let atOrAboveSeed = todayCompletionLevel.tutorialCompletionRank >= seedRank

        let standardPath = todayCompletionLevel == .seed && !hasCompletedGuidedJournal
        let upgradePath = pending051UpgradeOrientation && atOrAboveSeed

        guard standardPath || upgradePath else { return nil }

        let skipsCongratulationsPage = upgradePath && hasCompletedGuidedJournal
        return Outcome(skipsCongratulationsPage: skipsCongratulationsPage)
    }
}
