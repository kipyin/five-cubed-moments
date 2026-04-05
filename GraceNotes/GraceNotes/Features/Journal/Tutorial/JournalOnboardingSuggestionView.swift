import SwiftUI

struct JournalOnboardingSuggestionView: View {
    @Environment(\.todayJournalPalette) private var palette
    @Environment(\.interactionAccentPalette) private var interactionAccent
    let title: String
    let message: String
    let primaryActionTitle: String
    let secondaryActionTitle: String
    let onPrimaryAction: () -> Void
    let onSecondaryAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingRegular) {
            VStack(alignment: .leading, spacing: AppTheme.spacingTight) {
                Text(title)
                    .font(AppTheme.warmPaperMetaEmphasis)
                    .foregroundStyle(interactionAccent.accentText)

                Text(message)
                    .font(AppTheme.warmPaperBody)
                    .foregroundStyle(palette.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: AppTheme.spacingRegular) {
                Button(action: onPrimaryAction) {
                    Text(primaryActionTitle)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .tint(interactionAccent.accent)
                .foregroundStyle(interactionAccent.onAccent)

                Button(action: onSecondaryAction) {
                    Text(secondaryActionTitle)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.bordered)
                .tint(interactionAccent.accentText)
                .foregroundStyle(interactionAccent.accentText)
            }
            .font(AppTheme.warmPaperBody)
        }
        .padding(AppTheme.spacingRegular)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(palette.paper.opacity(palette.sectionPaperOpacity))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                .stroke(palette.inputBorder, lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
    }
}
