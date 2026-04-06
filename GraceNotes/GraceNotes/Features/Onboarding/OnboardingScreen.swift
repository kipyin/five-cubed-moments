import SwiftUI

struct OnboardingScreen: View {
    @Environment(\.interactionAccentPalette) private var interactionAccent
    let onGetStarted: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingSection) {
            Spacer(minLength: AppTheme.spacingWide)

            Text(String(localized: "Welcome to Grace Notes"))
                .font(AppTheme.warmPaperHeader)
                .foregroundStyle(AppTheme.settingsTextPrimary)

            VStack(alignment: .leading, spacing: AppTheme.spacingRegular) {
                Text(String(localized: "Start with one gratitude, and the rest will follow."))
                    .font(AppTheme.warmPaperMetaEmphasis)
                    .foregroundStyle(interactionAccent.secondaryControlTint)
            }
            .padding(AppTheme.spacingWide)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.settingsPaper)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge)
                    .stroke(AppTheme.journalInputBorder, lineWidth: 1)
            )

            Button(action: onGetStarted) {
                Text(String(localized: "Begin today's entry"))
                    .font(AppTheme.warmPaperBody.weight(.semibold))
                    .foregroundStyle(interactionAccent.primaryProminentForeground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.spacingRegular)
                    .background(interactionAccent.primaryProminentFill)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium))
            }
            .buttonStyle(WarmPaperPressStyle())
            .accessibilityHint(String(localized: "Opens Today and starts the guided first entry."))

            Spacer()
        }
        .padding(.horizontal, AppTheme.spacingWide)
        .padding(.vertical, AppTheme.spacingSection)
        .background(AppTheme.settingsBackground.ignoresSafeArea())
    }
}
