import Foundation
import SwiftData

enum JournalStreakSummaryRefresher {
    /// Computes streak summary from an entry list already loaded from the store (avoids a second full fetch).
    static func loadSummary(
        calculator: StreakCalculator,
        entries: [Journal],
        now: Date
    ) -> StreakSummary {
        calculator.summary(from: entries, now: now)
    }

    static func loadSummary(
        repository: JournalRepository,
        calculator: StreakCalculator,
        context: ModelContext,
        now: Date
    ) throws -> StreakSummary {
        let entries = try repository.fetchAllEntries(context: context)
        return loadSummary(calculator: calculator, entries: entries, now: now)
    }
}
