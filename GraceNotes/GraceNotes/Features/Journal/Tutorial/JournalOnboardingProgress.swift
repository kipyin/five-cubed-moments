import Foundation

enum JournalOnboardingSuggestion: CaseIterable {
    case reminders
    case aiFeatures
    case iCloudSync
}

enum JournalOnboardingStorageKeys {
    static let completedGuidedJournal = "journalOnboarding.completedGuidedJournal"
    static let dismissedRemindersSuggestion = "journalOnboarding.dismissedRemindersSuggestion"
    static let dismissedAISuggestion = "journalOnboarding.dismissedAISuggestion"
    static let dismissedICloudSuggestion = "journalOnboarding.dismissedICloudSuggestion"
    static let openedRemindersSuggestion = "journalOnboarding.openedRemindersSuggestion"
    static let openedAISuggestion = "journalOnboarding.openedAISuggestion"
    static let openedICloudSuggestion = "journalOnboarding.openedICloudSuggestion"
}

/// Per-install onboarding flags for the behavior-first journal path and optional feature suggestions.
final class JournalOnboardingProgress {
    private let defaults: UserDefaults

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

    static func resetAll(in defaults: UserDefaults = .standard) {
        let keys = [
            JournalOnboardingStorageKeys.completedGuidedJournal,
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
