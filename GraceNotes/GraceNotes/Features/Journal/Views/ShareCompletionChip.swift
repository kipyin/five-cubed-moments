import SwiftUI

/// Minimal completion label for share export (Figma mockup pill), separate from ``JournalCompletionPill``.
struct ShareCompletionChip: View {
    let completionLevel: JournalCompletionLevel
    let style: ShareCardStyle
    /// `true` when the share card uses the classic light palette; `false` for the dark card theme.
    var useLightCardPalette: Bool = true

    var body: some View {
        Text(localizedTitle)
            .font(style.completionChipLabelFont)
            .foregroundStyle(style.resolvedCompletionChipTextColor(useLightCardPalette: useLightCardPalette))
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(style.resolvedCompletionChipBackground(useLightCardPalette: useLightCardPalette))
            .clipShape(Capsule(style: .continuous))
            .accessibilityLabel(String(localized: "sharing.a11y.completionBadge"))
    }

    private var localizedTitle: String {
        switch completionLevel {
        case .soil:
            String(localized: "journal.growthStage.empty")
        case .sprout:
            String(localized: "journal.growthStage.started")
        case .twig:
            String(localized: "journal.growthStage.growing")
        case .leaf:
            String(localized: "journal.growthStage.balanced")
        case .bloom:
            String(localized: "journal.growthStage.full")
        }
    }
}
