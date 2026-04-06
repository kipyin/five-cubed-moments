import SwiftUI

enum SettingsOpenSystemSettingsButtonEmphasis {
    /// Outlined control for secondary contexts (e.g. notification permissions).
    case standard
    /// Filled control when opening Settings is the clear primary fix (e.g. iCloud not signed in).
    case prominent
}

struct SettingsOpenSystemSettingsButton: View {
    let action: () -> Void
    let accessibilityHint: String
    var emphasis: SettingsOpenSystemSettingsButtonEmphasis = .standard

    var body: some View {
        Button(action: action) {
            Text(String(localized: "Open Settings"))
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .font(AppTheme.warmPaperBody)
        .accessibilityHint(accessibilityHint)
        .modifier(OpenSystemSettingsButtonStyle(emphasis: emphasis))
    }
}

private struct OpenSystemSettingsButtonStyle: ViewModifier {
    @Environment(\.interactionAccentPalette) private var interactionAccent
    let emphasis: SettingsOpenSystemSettingsButtonEmphasis

    func body(content: Content) -> some View {
        switch emphasis {
        case .standard:
            content
                .buttonStyle(.bordered)
                .tint(interactionAccent.secondaryControlTint)
                .foregroundStyle(interactionAccent.secondaryControlTint)
        case .prominent:
            content
                .buttonStyle(.borderedProminent)
                .tint(interactionAccent.primaryProminentFill)
                .foregroundStyle(interactionAccent.primaryProminentForeground)
        }
    }
}
