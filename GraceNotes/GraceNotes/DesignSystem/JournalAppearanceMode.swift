import Foundation

/// Persisted Today tab journal chrome (`Standard` vs `Summer`). Scoped to Today-only in the UI.
enum JournalAppearanceMode: String, CaseIterable, Identifiable {
    case standard
    case summer

    var id: String { rawValue }
}

/// Which leaves implementation is active when ``JournalAppearanceMode/summer`` is on (for side-by-side comparison).
enum JournalSummerLeavesRenderer: String, CaseIterable, Identifiable {
    case video
    case native

    var id: String { rawValue }
}

enum JournalAppearanceStorageKeys {
    static let todayMode = "journalTodayAppearanceMode"
    static let summerLeavesRenderer = "journalSummerLeavesRenderer"
}
