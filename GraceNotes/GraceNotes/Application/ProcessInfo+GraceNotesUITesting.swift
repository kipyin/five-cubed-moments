import Foundation

extension ProcessInfo {
    /// Seeds many past-day journal rows so Review’s reflection rhythm strip is wider than the phone (#131 UI tests).
    static let graceNotesUITestWideReviewRhythmArgument = "-grace-notes-uitest-wide-review-rhythm"

    // MARK: - Local UAT (`simctl launch`, `make uat-axe`)

    /// Skip first-run welcome and open the main experience (fresh install + `make uat-axe` last step).
    static let graceNotesUATFastOnboardingArgument = "-grace-notes-uat-fast-onboarding"

    /// Mark post-Seed journey seen so plain UAT tabs stay visible on seeded data.
    /// UAT-10 still uses `-grace-notes-uat-post-seed`.
    static let graceNotesUATPostSeedSeenArgument = "-grace-notes-uat-mark-post-seed-journey-seen"

    /// Present the post-Seed full-screen journey on Today for capture (inert unless this flag is passed).
    static let graceNotesUATPostSeedJourneyArgument = "-grace-notes-uat-post-seed"

    /// Surface the Bloom (Summer) appearance toggle in Settings without requiring first-harvest progress.
    static let graceNotesUATUnlockSummerArg = "-grace-notes-uat-unlock-summer-toggle"

    static var graceNotesUATRequestsFastOnboarding: Bool {
        processInfo.arguments.contains(Self.graceNotesUATFastOnboardingArgument)
    }

    static var graceNotesUATMarksPostSeedJourneySeen: Bool {
        processInfo.arguments.contains(Self.graceNotesUATPostSeedSeenArgument)
    }

    static var graceNotesUATRequestsPostSeedJourney: Bool {
        processInfo.arguments.contains(Self.graceNotesUATPostSeedJourneyArgument)
    }

    /// True when UAT should show the Bloom toggle without real first-harvest progress.
    static var graceNotesUATUnlocksSummerToggle: Bool {
        processInfo.arguments.contains(Self.graceNotesUATUnlockSummerArg)
    }

    /// True when the app runs under UI tests: UITest bundle path from XCTest, or `-ui-testing` launch argument.
    static var graceNotesIsRunningUITests: Bool {
        let processInfo = Self.processInfo
        let isUITestBundle = processInfo.environment["XCTestBundlePath"]?.contains("UITests") == true
        let hasUITestLaunchArgument = processInfo.arguments.contains("-ui-testing")
        return isUITestBundle || hasUITestLaunchArgument
    }

    static var graceNotesUITestRequestsWideReviewRhythmSeed: Bool {
        processInfo.arguments.contains(Self.graceNotesUITestWideReviewRhythmArgument)
    }
}
