import Foundation
import SwiftUI

/// User-chosen accent for interaction chrome (tab tint, toggles, primary actions).
/// Body paper and tier greens stay stable.
enum AccentPreference: String, CaseIterable, Identifiable {
    case terracotta
    case ocean
    case plum
    case forest

    var id: String { rawValue }

    static func resolveStored(rawValue: String) -> AccentPreference {
        AccentPreference(rawValue: rawValue) ?? .terracotta
    }

    var localizedTitle: String {
        switch self {
        case .terracotta:
            return String(localized: "Settings.advanced.accent.terracotta")
        case .ocean:
            return String(localized: "Settings.advanced.accent.ocean")
        case .plum:
            return String(localized: "Settings.advanced.accent.plum")
        case .forest:
            return String(localized: "Settings.advanced.accent.forest")
        }
    }
}

enum JournalAppearanceStorageKeys {
    static let todayMode = "journalTodayAppearanceMode"
    static let accentPreference = "journalAccentPreference"
}
