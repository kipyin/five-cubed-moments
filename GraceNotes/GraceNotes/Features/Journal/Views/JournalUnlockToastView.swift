import SwiftUI

/// First-time congratulations variant for unlock toasts (issue #60).
enum JournalUnlockMilestoneHighlight: Equatable {
    case none
    case firstOneOneOne
    case firstBalanced
    case firstFull
}

/// Brief encouragement when journal completion moves up a tier.
struct JournalUnlockToastView: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.todayJournalPalette) private var palette

    let level: JournalCompletionLevel
    var milestoneHighlight: JournalUnlockMilestoneHighlight = .none

    var body: some View {
        Text(message)
            .font(AppTheme.warmPaperBody)
            .foregroundStyle(palette.textPrimary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppTheme.spacingWide)
            .padding(.vertical, AppTheme.spacingRegular)
            .background(palette.paper.opacity(palette.sectionPaperOpacity))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                    .stroke(borderTint, lineWidth: 1)
            )
            .journalToastOuterGlow(accentColor: glowAccentColor, reduceTransparency: reduceTransparency)
    }

    private var message: String {
        switch milestoneHighlight {
        case .firstOneOneOne:
            return String(localized: "First time with one line in each section. Nice work.")
        case .firstBalanced:
            return String(
                localized: "Your first Leaf day. Each section has at least three lines. Keep going toward Bloom."
            )
        case .firstFull:
            return String(
                localized:
                    "Your first Bloom day. Each section has five lines. Add reading notes or reflections when you want."
            )
        case .none:
            break
        }
        switch level {
        case .empty:
            return ""
        case .started:
            return String(localized: "You reached Sprout today.")
        case .growing:
            return String(localized: "Keep going in each section toward Leaf.")
        case .balanced:
            return String(localized: "You reached Leaf today.")
        case .full:
            return String(localized: "You reached Bloom today. All five lines are filled in each section.")
        }
    }

    private var borderTint: Color {
        switch level {
        case .empty:
            return palette.border
        case .started:
            return palette.quickCheckInBorder
        case .growing:
            return palette.standardBorder
        case .balanced:
            return palette.standardBorder
        case .full:
            return palette.fullBorder
        }
    }

    private var shadowTint: Color {
        switch level {
        case .empty:
            return .clear
        case .started:
            return palette.quickCheckInGlow
        case .growing:
            return palette.standardGlow
        case .balanced:
            return palette.standardGlow
        case .full:
            return palette.fullGlow
        }
    }

    private var glowAccentColor: Color {
        switch level {
        case .empty:
            return palette.border
        default:
            return shadowTint
        }
    }
}
