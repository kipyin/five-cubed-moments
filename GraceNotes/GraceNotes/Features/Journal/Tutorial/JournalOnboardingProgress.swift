import Foundation

enum JournalOnboardingSuggestion: CaseIterable {
    case reminders
    case aiFeatures
    case iCloudSync
}

enum JournalOnboardingStorageKeys {
    static let completedGuidedJournal = "journalOnboarding.completedGuidedJournal"
    static let hasSeenPostSeedJourney = "journalOnboarding.hasSeenPostSeedJourney"
    static let dismissedRemindersSuggestion = "journalOnboarding.dismissedRemindersSuggestion"
    static let dismissedAISuggestion = "journalOnboarding.dismissedAISuggestion"
    static let dismissedICloudSuggestion = "journalOnboarding.dismissedICloudSuggestion"
    static let openedRemindersSuggestion = "journalOnboarding.openedRemindersSuggestion"
    static let openedAISuggestion = "journalOnboarding.openedAISuggestion"
    static let openedICloudSuggestion = "journalOnboarding.openedICloudSuggestion"
}

private enum LegacyJournalOnboardingStorageKeys {
    static let pending051UpgradeOrientation = "journalOnboarding.pending051UpgradeOrientation"
    static let pending051GuidedJournalBranchResolution = "journalOnboarding.pending051GuidedJournalBranchResolution"
}

/// Per-install onboarding flags for the behavior-first journal path and optional feature suggestions.
final class JournalOnboardingProgress {
    private let defaults: UserDefaults

    private static let legacyTutorialKeys = [
        JournalTutorialStorageKeys.dismissedSeedGuidance,
        JournalTutorialStorageKeys.dismissedHarvestGuidance,
        JournalTutorialStorageKeys.celebratedFirstSeed,
        JournalTutorialStorageKeys.celebratedFirstHarvest
    ]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var hasCompletedGuidedJournal: Bool {
        get { defaults.bool(forKey: JournalOnboardingStorageKeys.completedGuidedJournal) }
        set { defaults.set(newValue, forKey: JournalOnboardingStorageKeys.completedGuidedJournal) }
    }

    func hasDismissedSuggestion(_ suggestion: JournalOnboardingSuggestion) -> Bool {
        defaults.bool(forKey: dismissedKey(for: suggestion))
    }

    func setDismissed(_ dismissed: Bool, for suggestion: JournalOnboardingSuggestion) {
        defaults.set(dismissed, forKey: dismissedKey(for: suggestion))
    }

    func hasOpenedSuggestion(_ suggestion: JournalOnboardingSuggestion) -> Bool {
        defaults.bool(forKey: openedKey(for: suggestion))
    }

    func setOpened(_ opened: Bool, for suggestion: JournalOnboardingSuggestion) {
        defaults.set(opened, forKey: openedKey(for: suggestion))
    }

    static func resolvedHasCompletedGuidedJournal(using defaults: UserDefaults = .standard) -> Bool {
        if let storedValue = defaults.object(forKey: JournalOnboardingStorageKeys.completedGuidedJournal) as? Bool {
            return storedValue
        }

        let migratedValue = shouldTreatInstallAsPreviouslyOnboarded(using: defaults)
        defaults.set(migratedValue, forKey: JournalOnboardingStorageKeys.completedGuidedJournal)
        return migratedValue
    }

    /// Removes version-gated upgrade keys from older builds; safe to call every launch.
    static func migrateLegacyPostSeedOrientationFlagsIfNeeded(using defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: LegacyJournalOnboardingStorageKeys.pending051UpgradeOrientation)
        defaults.removeObject(forKey: LegacyJournalOnboardingStorageKeys.pending051GuidedJournalBranchResolution)
    }

    static func resetAll(in defaults: UserDefaults = .standard) {
        let keys = [
            JournalOnboardingStorageKeys.completedGuidedJournal,
            LegacyJournalOnboardingStorageKeys.pending051UpgradeOrientation,
            LegacyJournalOnboardingStorageKeys.pending051GuidedJournalBranchResolution,
            JournalOnboardingStorageKeys.hasSeenPostSeedJourney,
            JournalOnboardingStorageKeys.dismissedRemindersSuggestion,
            JournalOnboardingStorageKeys.dismissedAISuggestion,
            JournalOnboardingStorageKeys.dismissedICloudSuggestion,
            JournalOnboardingStorageKeys.openedRemindersSuggestion,
            JournalOnboardingStorageKeys.openedAISuggestion,
            JournalOnboardingStorageKeys.openedICloudSuggestion
        ]
        for key in keys {
            defaults.removeObject(forKey: key)
        }
        AppLaunchVersionTracker.resetLaunchTracking(in: defaults)
    }

    private static func shouldTreatInstallAsPreviouslyOnboarded(using defaults: UserDefaults) -> Bool {
        if defaults.object(forKey: FirstRunOnboardingStorageKeys.completed) as? Bool == true {
            return true
        }

        if defaults.object(forKey: ReminderSettings.timeIntervalKey) != nil {
            return true
        }

        if defaults.object(forKey: SummarizerProvider.useCloudUserDefaultsKey) != nil {
            return true
        }

        if defaults.object(forKey: ReviewInsightsProvider.legacyAIFeaturesUserDefaultsKey) != nil {
            return true
        }

        return legacyTutorialKeys.contains { defaults.object(forKey: $0) != nil }
    }

    private func dismissedKey(for suggestion: JournalOnboardingSuggestion) -> String {
        switch suggestion {
        case .reminders:
            return JournalOnboardingStorageKeys.dismissedRemindersSuggestion
        case .aiFeatures:
            return JournalOnboardingStorageKeys.dismissedAISuggestion
        case .iCloudSync:
            return JournalOnboardingStorageKeys.dismissedICloudSuggestion
        }
    }

    private func openedKey(for suggestion: JournalOnboardingSuggestion) -> String {
        switch suggestion {
        case .reminders:
            return JournalOnboardingStorageKeys.openedRemindersSuggestion
        case .aiFeatures:
            return JournalOnboardingStorageKeys.openedAISuggestion
        case .iCloudSync:
            return JournalOnboardingStorageKeys.openedICloudSuggestion
        }
    }
}
