import SwiftUI

struct JournalOnboardingGuidanceView: View {
    @Environment(\.todayJournalPalette) private var palette
    @Environment(\.interactionAccentPalette) private var interactionAccent
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingTight) {
            Text(title)
                .font(AppTheme.warmPaperMetaEmphasis)
                .foregroundStyle(interactionAccent.accentText)

            Text(message)
                .font(AppTheme.warmPaperBody)
                .foregroundStyle(palette.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppTheme.spacingRegular)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(palette.paper.opacity(palette.sectionPaperOpacity))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                .stroke(palette.inputBorder, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }
}
