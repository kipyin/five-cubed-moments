import XCTest
@testable import GraceNotes

final class JournalOnboardingProgressTests: XCTestCase {
    func test_resetAll_clearsGuidedJournalAndSuggestionFlags() {
        let defaults = makeIsolatedDefaults()
        let progress = JournalOnboardingProgress(defaults: defaults)
        progress.hasCompletedGuidedJournal = true
        progress.setDismissed(true, for: .reminders)
        progress.setOpened(true, for: .aiFeatures)
        progress.setDismissed(true, for: .iCloudSync)

        JournalOnboardingProgress.resetAll(in: defaults)

        let reloadedProgress = JournalOnboardingProgress(defaults: defaults)
        XCTAssertFalse(reloadedProgress.hasCompletedGuidedJournal)
        XCTAssertFalse(reloadedProgress.hasDismissedSuggestion(.reminders))
        XCTAssertFalse(reloadedProgress.hasOpenedSuggestion(.aiFeatures))
        XCTAssertFalse(reloadedProgress.hasDismissedSuggestion(.iCloudSync))
    }
}

private extension JournalOnboardingProgressTests {
    func makeIsolatedDefaults() -> UserDefaults {
        let suiteName = "JournalOnboardingProgressTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }
}
