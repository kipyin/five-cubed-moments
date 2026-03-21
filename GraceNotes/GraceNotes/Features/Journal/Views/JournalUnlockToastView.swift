import SwiftUI

/// Brief encouragement when journal completion moves up a tier.
struct JournalUnlockToastView: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var iconBounceTrigger = 0

    let level: JournalCompletionLevel

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            toastIcon
            Text(message)
                .font(AppTheme.warmPaperBody)
                .foregroundStyle(AppTheme.journalTextPrimary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, AppTheme.spacingWide)
        .padding(.vertical, AppTheme.spacingRegular)
        .background(AppTheme.journalPaper)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                .stroke(borderTint, lineWidth: 1)
        )
        .journalToastOuterGlow(accentColor: glowAccentColor, reduceTransparency: reduceTransparency)
    }

    @ViewBuilder
    private var toastIcon: some View {
        if shouldPlayIconBounce {
            Image(systemName: iconName)
                .foregroundStyle(iconTint)
                .symbolEffect(.bounce, value: iconBounceTrigger)
                .onAppear {
                    iconBounceTrigger += 1
                }
        } else {
            Image(systemName: iconName)
                .foregroundStyle(iconTint)
        }
    }

    private var shouldPlayIconBounce: Bool {
        !reduceMotion && (level == .standardReflection || level == .fullFiveCubed)
    }

    private var message: String {
        switch level {
        case .quickCheckIn:
            return String(localized: "You planted a seed today.")
        case .standardReflection:
            return String(localized: "You reached Harvest.")
        case .fullFiveCubed:
            return String(localized: "You completed the full rhythm today.")
        case .none:
            return ""
        }
    }

    private var iconName: String {
        switch level {
        case .quickCheckIn:
            return "leaf.fill"
        case .standardReflection:
            return "sparkles.rectangle.stack.fill"
        case .fullFiveCubed:
            return "checkmark.circle.fill"
        case .none:
            return "leaf.fill"
        }
    }

    private var iconTint: Color {
        switch level {
        case .quickCheckIn:
            return AppTheme.journalQuickCheckInText
        case .standardReflection:
            return AppTheme.journalStandardText
        case .fullFiveCubed:
            return AppTheme.journalFullText
        case .none:
            return AppTheme.journalTextMuted
        }
    }

    private var borderTint: Color {
        switch level {
        case .quickCheckIn:
            return AppTheme.journalQuickCheckInBorder
        case .standardReflection:
            return AppTheme.journalStandardBorder
        case .fullFiveCubed:
            return AppTheme.journalFullBorder
        case .none:
            return AppTheme.journalBorder
        }
    }

    private var shadowTint: Color {
        switch level {
        case .quickCheckIn:
            return AppTheme.journalQuickCheckInGlow
        case .standardReflection:
            return AppTheme.journalStandardGlow
        case .fullFiveCubed:
            return AppTheme.journalFullGlow
        case .none:
            return .clear
        }
    }

    private var glowAccentColor: Color {
        switch level {
        case .none:
            return AppTheme.journalBorder
        default:
            return shadowTint
        }
    }
}
