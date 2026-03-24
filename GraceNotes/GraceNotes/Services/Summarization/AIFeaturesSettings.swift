import Foundation

/// Central enablement for cloud AI (summarization + review insights). Persisted under `useCloudSummarization`.
/// Older builds stored a duplicate toggle under `useAIReviewInsights`;
/// `ReviewInsightsProvider.migrateLegacyAIFeaturesToggleIfNeeded()` merges that into the canonical key at launch.
enum AIFeaturesSettings {
    static let enabledUserDefaultsKey = "useCloudSummarization"
    static let legacyAIReviewInsightsKey = "useAIReviewInsights"

    static func isEnabled(using defaults: UserDefaults = .standard) -> Bool {
        defaults.object(forKey: enabledUserDefaultsKey) as? Bool ?? false
    }

    static func setEnabled(_ isEnabled: Bool, using defaults: UserDefaults = .standard) {
        defaults.set(isEnabled, forKey: enabledUserDefaultsKey)
        defaults.removeObject(forKey: legacyAIReviewInsightsKey)
    }
}
