import SwiftUI

/// Tier-colored fills shared by inline completion chrome (pill, toolbar chip).
enum JournalCompletionTierSurface {
    static func backgroundFill(for level: JournalCompletionLevel, palette: TodayJournalPalette) -> AnyShapeStyle {
        switch level {
        case .soil:
            return AnyShapeStyle(palette.background)
        case .sprout:
            return AnyShapeStyle(palette.quickCheckInBackground)
        case .twig, .leaf:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [palette.standardBackgroundStart, palette.standardBackgroundEnd],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .bloom:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [palette.fullBackgroundStart, palette.fullBackgroundEnd],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
}
