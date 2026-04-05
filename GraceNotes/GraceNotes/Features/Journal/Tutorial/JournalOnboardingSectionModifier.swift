import SwiftUI

extension JournalOnboardingSectionState {
    var showsGuidedChrome: Bool {
        self != .standard
    }

    var isLocked: Bool {
        if case .locked = self {
            return true
        }
        return false
    }

    var guidanceNote: String? {
        if case .locked(let reason) = self {
            return reason
        }
        return nil
    }

    func titleColor(palette: TodayJournalPalette) -> Color {
        switch self {
        case .standard, .available:
            return palette.textPrimary
        case .active:
            return palette.interactionAccentText
        case .locked:
            return palette.textMuted
        }
    }

    func containerBackground(palette: TodayJournalPalette) -> Color {
        switch self {
        case .standard:
            return .clear
        case .active:
            return palette.paper.opacity(0.9 * palette.sectionPaperOpacity)
        case .available:
            return palette.paper.opacity(0.58 * palette.sectionPaperOpacity)
        case .locked:
            return palette.paper.opacity(0.42 * palette.sectionPaperOpacity)
        }
    }

    func containerBorder(palette: TodayJournalPalette) -> Color {
        switch self {
        case .standard:
            return .clear
        case .active:
            return palette.inputBorder
        case .available:
            return palette.border
        case .locked:
            return palette.border.opacity(0.72)
        }
    }

    func contentOpacity(isTransitioning: Bool = false) -> Double {
        switch self {
        case .standard:
            return isTransitioning ? 0.78 : 1
        case .active:
            return isTransitioning ? 0.82 : 1
        case .available:
            return isTransitioning ? 0.76 : 0.94
        case .locked:
            return isTransitioning ? 0.64 : 0.7
        }
    }
}

struct JournalOnboardingSectionModifier: ViewModifier {
    @Environment(\.todayJournalPalette) private var palette
    let state: JournalOnboardingSectionState
    let isTransitioning: Bool

    func body(content: Content) -> some View {
        content
            .padding(state.showsGuidedChrome ? AppTheme.spacingRegular : 0)
            .background {
                if state.showsGuidedChrome {
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                        .fill(state.containerBackground(palette: palette))
                }
            }
            .overlay {
                if state.showsGuidedChrome {
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                        .stroke(state.containerBorder(palette: palette), lineWidth: 1)
                }
            }
            .opacity(state.contentOpacity(isTransitioning: isTransitioning))
    }
}

extension View {
    func journalOnboardingSectionStyle(
        _ state: JournalOnboardingSectionState,
        isTransitioning: Bool = false
    ) -> some View {
        modifier(JournalOnboardingSectionModifier(state: state, isTransitioning: isTransitioning))
    }
}
