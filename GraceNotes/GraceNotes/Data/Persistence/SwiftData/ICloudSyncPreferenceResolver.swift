import Foundation

enum ICloudSyncPreferenceResolver {
    private static let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    private static let reminderTimeIntervalKey = "dailyReminderTimeInterval"
    private static let useCloudSummarizationKey = "useCloudSummarization"
    private static let useAIReviewInsightsKey = "useAIReviewInsights"

    private static let legacyTutorialKeys = [
        "journalTutorial.dismissedSeedGuidance",
        "journalTutorial.dismissedHarvestGuidance",
        "journalTutorial.celebratedFirstSeed",
        "journalTutorial.celebratedFirstHarvest"
    ]

    private static let onboardingKeys = [
        "journalOnboarding.completedGuidedJournal",
        "journalOnboarding.dismissedRemindersSuggestion",
        "journalOnboarding.dismissedAISuggestion",
        "journalOnboarding.dismissedICloudSuggestion",
        "journalOnboarding.openedRemindersSuggestion",
        "journalOnboarding.openedAISuggestion",
        "journalOnboarding.openedICloudSuggestion"
    ]

    static func resolvedCloudSyncEnabled(using defaults: UserDefaults = .standard) -> Bool {
        if let storedPreference = defaults.object(forKey: PersistenceController.iCloudSyncEnabledKey) as? Bool {
            return storedPreference
        }

        let resolvedPreference = shouldPreserveExistingInstallAsEnabled(using: defaults)
        defaults.set(resolvedPreference, forKey: PersistenceController.iCloudSyncEnabledKey)
        return resolvedPreference
    }

    static func shouldPreserveExistingInstallAsEnabled(using defaults: UserDefaults = .standard) -> Bool {
        if defaults.object(forKey: hasCompletedOnboardingKey) as? Bool == true {
            return true
        }

        if defaults.object(forKey: reminderTimeIntervalKey) != nil {
            return true
        }

        if defaults.object(forKey: useCloudSummarizationKey) != nil {
            return true
        }

        if defaults.object(forKey: useAIReviewInsightsKey) != nil {
            return true
        }

        let continuityKeys = legacyTutorialKeys + onboardingKeys
        return continuityKeys.contains { defaults.object(forKey: $0) != nil }
    }
}
