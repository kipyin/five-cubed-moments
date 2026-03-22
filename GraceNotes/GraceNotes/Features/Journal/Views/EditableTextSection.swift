import SwiftUI

/// A section with a title and multiline TextEditor. Used for Reading Notes and Reflections.
struct EditableTextSection: View {
    let title: String
    @Binding var text: String
    let minHeight: CGFloat
    let onboardingState: JournalOnboardingSectionState
    let inputFocus: FocusState<Bool>.Binding?

    init(
        title: String,
        text: Binding<String>,
        minHeight: CGFloat = 120,
        onboardingState: JournalOnboardingSectionState = .standard,
        inputFocus: FocusState<Bool>.Binding? = nil
    ) {
        self.title = title
        self._text = text
        self.minHeight = minHeight
        self.onboardingState = onboardingState
        self.inputFocus = inputFocus
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingTight) {
            Text(title)
                .font(AppTheme.warmPaperHeader)
                .foregroundStyle(titleColor)
            if let guidanceNote = onboardingState.guidanceNote {
                Text(guidanceNote)
                    .font(AppTheme.warmPaperMeta)
                    .foregroundStyle(AppTheme.journalTextMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            textEditor
        }
        .padding(showsGuidedContainer ? AppTheme.spacingRegular : 0)
        .background {
            if showsGuidedContainer {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                    .fill(containerBackground)
            }
        }
        .overlay {
            if showsGuidedContainer {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                    .stroke(containerBorder, lineWidth: 1)
            }
        }
        .opacity(contentOpacity)
    }

    @ViewBuilder
    private var textEditor: some View {
        let editor = TextEditor(text: $text)
            .font(AppTheme.warmPaperBody)
            .foregroundStyle(AppTheme.journalTextPrimary)
            .scrollContentBackground(.hidden)
            .frame(minHeight: minHeight)
            .warmPaperInputStyle()
            .disabled(onboardingState.isLocked)
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
        if let inputFocus {
            editor.focused(inputFocus)
        } else {
            editor
        }
    }

    private var showsGuidedContainer: Bool {
        onboardingState != .standard
    }

    private var titleColor: Color {
        switch onboardingState {
        case .standard, .available:
            return AppTheme.journalTextPrimary
        case .active:
            return AppTheme.accentText
        case .locked:
            return AppTheme.journalTextMuted
        }
    }

    private var containerBackground: Color {
        switch onboardingState {
        case .standard:
            return .clear
        case .active:
            return AppTheme.journalPaper.opacity(0.9)
        case .available:
            return AppTheme.journalPaper.opacity(0.58)
        case .locked:
            return AppTheme.journalPaper.opacity(0.42)
        }
    }

    private var containerBorder: Color {
        switch onboardingState {
        case .standard:
            return .clear
        case .active:
            return AppTheme.journalInputBorder
        case .available:
            return AppTheme.journalBorder
        case .locked:
            return AppTheme.journalBorder.opacity(0.72)
        }
    }

    private var contentOpacity: Double {
        switch onboardingState {
        case .standard:
            return 1
        case .active:
            return 1
        case .available:
            return 0.94
        case .locked:
            return 0.7
        }
    }
}
