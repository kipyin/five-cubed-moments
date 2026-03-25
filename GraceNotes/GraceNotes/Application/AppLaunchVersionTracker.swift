import Foundation

enum GraceNotesLaunchStorageKeys {
    static let lastLaunchedMarketingVersion = "graceNotes.lastLaunchedMarketingVersion"
    static let lastLaunchedBundleVersion = "graceNotes.lastLaunchedBundleVersion"
}

/// Persists last launched marketing and bundle (support / continuity; not used for tutorial gating).
enum AppLaunchVersionTracker {
    /// Call once per process launch before resolving guided-journal migration.
    /// - Parameters:
    ///   - currentMarketingVersionOverride: Tests inject a version string instead of reading the host bundle.
    ///   - currentBundleVersionOverride: Tests inject a build number instead of reading the host bundle.
    static func applyLaunch(
        bundle: Bundle = .main,
        defaults: UserDefaults = .standard,
        currentMarketingVersionOverride: String? = nil,
        currentBundleVersionOverride: Int? = nil
    ) {
        let currentMarketing = currentMarketingVersionOverride ?? bundle.graceNotesMarketingVersion ?? "0"
        let currentBundle = currentBundleVersionOverride ?? bundle.graceNotesBundleVersion

        defaults.set(currentMarketing, forKey: GraceNotesLaunchStorageKeys.lastLaunchedMarketingVersion)
        if let currentBundle {
            defaults.set(currentBundle, forKey: GraceNotesLaunchStorageKeys.lastLaunchedBundleVersion)
        } else {
            defaults.removeObject(forKey: GraceNotesLaunchStorageKeys.lastLaunchedBundleVersion)
        }
    }

    static func resetLaunchTracking(in defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: GraceNotesLaunchStorageKeys.lastLaunchedMarketingVersion)
        defaults.removeObject(forKey: GraceNotesLaunchStorageKeys.lastLaunchedBundleVersion)
    }
}
