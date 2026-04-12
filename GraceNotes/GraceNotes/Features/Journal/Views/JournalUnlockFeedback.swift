import SwiftUI

/// First-time congratulations variant for unlock feedback (issue #60).
enum JournalUnlockMilestoneHighlight: Equatable {
    case none
    case firstOneOneOne
    case firstBalanced
    case firstFull
}

/// Where journal tier/milestone unlock feedback is anchored (issue #225).
enum JournalUnlockFeedbackPlacement: Equatable {
    case none
    case headerRibbon
    case toolbarBanner

    static func resolve(isUnlockPresent: Bool, stickyCompletionRevealed: Bool) -> Self {
        guard isUnlockPresent else { return .none }
        if stickyCompletionRevealed { return .toolbarBanner }
        return .headerRibbon
    }
}

enum JournalUnlockFeedbackMessage {

    static func message(
        for level: JournalCompletionLevel,
        milestone: JournalUnlockMilestoneHighlight
    ) -> String {
        switch milestone {
        case .firstOneOneOne:
            return String(localized: "journal.guidance.firstTimeOneLineEach")
        case .firstBalanced:
            return String(localized: "journal.guidance.firstLeafDay")
        case .firstFull:
            return String(localized: "journal.guidance.firstBloomDay")
        case .none:
            switch level {
            case .soil:
                return ""
            case .sprout:
                return String(localized: "journal.guidance.reachedSproutToday")
            case .twig:
                return String(localized: "journal.guidance.towardLeafShort")
            case .leaf:
                return String(localized: "journal.guidance.reachedLeafToday")
            case .bloom:
                return String(localized: "journal.guidance.reachedBloomToday")
            }
        }
    }
}

/// High-contrast unlock encouragement — same card treatment in the header and under the toolbar.
struct JournalUnlockFeedbackSurface: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.todayJournalPalette) private var palette

    let level: JournalCompletionLevel
    var milestoneHighlight: JournalUnlockMilestoneHighlight = .none

    var body: some View {
        let raw = JournalUnlockFeedbackMessage.message(for: level, milestone: milestoneHighlight)
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty {
            EmptyView()
        } else {
            content(text: text)
        }
    }

    private func content(text: String) -> some View {
        Text(text)
            .font(AppTheme.warmPaperBody)
            .foregroundStyle(palette.textPrimary)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppTheme.spacingWide)
            .padding(.vertical, AppTheme.spacingRegular)
            .background { background }
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous)
                    .stroke(borderTint, lineWidth: 1.5)
            }
            .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
    }

    @ViewBuilder
    private var background: some View {
        // Warm paper tokens only (no system Materials)—matches journal section chrome and avoids grey bars.
        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous)
            .fill(
                reduceTransparency
                    ? palette.paper
                    : palette.paper.opacity(palette.sectionPaperOpacity)
            )
    }

    private var borderTint: Color {
        switch level {
        case .soil:
            return palette.border
        case .sprout:
            return palette.quickCheckInBorder
        case .twig, .leaf:
            return palette.standardBorder
        case .bloom:
            return palette.fullBorder
        }
    }

    private var shadowColor: Color {
        switch level {
        case .soil:
            return Color.black.opacity(0.12)
        case .sprout:
            return palette.quickCheckInGlow.opacity(0.18)
        case .twig, .leaf:
            return palette.standardGlow.opacity(0.18)
        case .bloom:
            return palette.fullGlow.opacity(0.18)
        }
    }
}
