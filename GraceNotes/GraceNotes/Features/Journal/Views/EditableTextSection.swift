import SwiftUI

/// A section with a title and multiline TextEditor. Used for Reading Notes and Reflections.
struct EditableTextSection: View {
    let title: String
    @Binding var text: String
    let minHeight: CGFloat

    init(
        title: String,
        text: Binding<String>,
        minHeight: CGFloat = 120
    ) {
        self.title = title
        self._text = text
        self.minHeight = minHeight
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingTight) {
            Text(title)
                .font(AppTheme.warmPaperHeader)
                .foregroundStyle(AppTheme.journalTextPrimary)
            TextEditor(text: $text)
                .font(AppTheme.warmPaperBody)
                .foregroundStyle(AppTheme.journalTextPrimary)
                .scrollContentBackground(.hidden)
                .frame(minHeight: minHeight)
                .warmPaperInputStyle()
                .accessibilityLabel(
                    String(
                        format: String(localized: "%@ text"),
                        locale: Locale.current,
                        title
                    )
                )
                .accessibilityHint(
                    String(
                        format: String(localized: "Write your %@ here."),
                        locale: Locale.current,
                        title
                    )
                )
        }
    }
}
