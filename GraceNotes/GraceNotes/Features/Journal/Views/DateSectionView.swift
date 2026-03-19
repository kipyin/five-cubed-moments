import SwiftUI

/// Displays the journal entry completion status.
struct DateSectionView: View {
    private enum CompletionBadgeInfo {
        case dailyRhythm
        case complete

        var description: String {
            switch self {
            case .dailyRhythm:
                return String(localized: "Daily Rhythm means you checked in with meaningful progress today.")
            case .complete:
                return String(localized: "Complete means you finished the full journal reflection for today.")
            }
        }
    }

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @State private var selectedBadgeInfo: CompletionBadgeInfo?

    let completionLevel: JournalCompletionLevel
    let celebratingLevel: JournalCompletionLevel?

    var body: some View {
        completionStatusLabel
            .frame(maxWidth: .infinity, alignment: .leading)
        .alert(String(localized: "Completion status"), isPresented: completionInfoIsPresented) {
            Button(String(localized: "OK"), role: .cancel) {}
        } message: {
            Text(selectedBadgeInfo?.description ?? "")
        }
    }

    private var completionStatusLabel: some View {
        Group {
            switch completionLevel {
            case .quickCheckIn:
                Button {
                    selectedBadgeInfo = .dailyRhythm
                } label: {
                    levelSurface(level: .quickCheckIn, isCelebrating: celebratingLevel == .quickCheckIn) {
                        Label(String(localized: "Daily Rhythm"), systemImage: "sparkles")
                            .font(AppTheme.warmPaperMetaEmphasis)
                            .foregroundStyle(AppTheme.journalQuickCheckInText)
                    }
                }
                .buttonStyle(.plain)
            case .standardReflection:
                Button {
                    selectedBadgeInfo = .complete
                } label: {
                    levelSurface(level: .standardReflection, isCelebrating: celebratingLevel == .standardReflection) {
                        Label(
                            String(localized: "Complete"),
                            systemImage: celebratingLevel == .standardReflection
                                ? "sparkles.rectangle.stack.fill"
                                : "sparkles.rectangle.stack"
                        )
                        .font(AppTheme.warmPaperMetaEmphasis)
                        .foregroundStyle(AppTheme.journalStandardText)
                    }
                }
                .buttonStyle(.plain)
            case .fullFiveCubed:
                Button {
                    selectedBadgeInfo = .complete
                } label: {
                    levelSurface(level: .fullFiveCubed, isCelebrating: celebratingLevel == .fullFiveCubed) {
                        Label(
                            String(localized: "Complete"),
                            systemImage: celebratingLevel == .fullFiveCubed
                                ? "checkmark.circle.fill"
                                : "checkmark.circle"
                        )
                        .font(AppTheme.warmPaperMetaEmphasis)
                        .foregroundStyle(AppTheme.journalFullText)
                    }
                }
                .buttonStyle(.plain)
            case .none:
                Label(String(localized: "In progress"), systemImage: "pencil.circle")
                    .font(AppTheme.warmPaperMetaEmphasis)
                    .foregroundStyle(AppTheme.journalTextMuted)
            }
        }
        .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 2)
        .fixedSize(horizontal: false, vertical: true)
        .multilineTextAlignment(.leading)
    }

    private func levelSurface<Content: View>(
        level: JournalCompletionLevel,
        isCelebrating: Bool,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(.horizontal, AppTheme.spacingRegular)
            .padding(.vertical, AppTheme.spacingTight)
            .frame(minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                    .fill(backgroundFill(for: level))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                    .stroke(borderColor(for: level), lineWidth: 1)
            )
            .scaleEffect(scaleFactor(for: level, isCelebrating: isCelebrating))
            .shadow(
                color: shadowColor(for: level, isCelebrating: isCelebrating),
                radius: shadowRadius(for: level, isCelebrating: isCelebrating),
                x: 0,
                y: isCelebrating && !reduceTransparency ? 2 : 0
            )
            .animation(
                reduceMotion ? nil : AppTheme.celebrationPulseAnimation(for: level),
                value: isCelebrating
            )
    }

    private func backgroundFill(for level: JournalCompletionLevel) -> AnyShapeStyle {
        switch level {
        case .quickCheckIn:
            return AnyShapeStyle(AppTheme.journalQuickCheckInBackground)
        case .standardReflection:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [AppTheme.journalStandardBackgroundStart, AppTheme.journalStandardBackgroundEnd],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .fullFiveCubed:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [AppTheme.journalFullBackgroundStart, AppTheme.journalFullBackgroundEnd],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .none:
            return AnyShapeStyle(AppTheme.journalBackground)
        }
    }

    private func borderColor(for level: JournalCompletionLevel) -> Color {
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

    private func scaleFactor(for level: JournalCompletionLevel, isCelebrating: Bool) -> CGFloat {
        guard isCelebrating, !reduceMotion else { return 1.0 }
        switch level {
        case .quickCheckIn:
            return 1.008
        case .standardReflection:
            return 1.015
        case .fullFiveCubed:
            return 1.02
        case .none:
            return 1.0
        }
    }

    private func shadowColor(for level: JournalCompletionLevel, isCelebrating: Bool) -> Color {
        guard isCelebrating, !reduceTransparency else { return .clear }
        switch level {
        case .quickCheckIn:
            return AppTheme.journalQuickCheckInGlow.opacity(0.25)
        case .standardReflection:
            return AppTheme.journalStandardGlow.opacity(0.4)
        case .fullFiveCubed:
            return AppTheme.journalFullGlow.opacity(0.48)
        case .none:
            return .clear
        }
    }

    private func shadowRadius(for level: JournalCompletionLevel, isCelebrating: Bool) -> CGFloat {
        guard isCelebrating, !reduceTransparency else { return 0 }
        switch level {
        case .quickCheckIn:
            return 4
        case .standardReflection:
            return 8
        case .fullFiveCubed:
            return 11
        case .none:
            return 0
        }
    }

    private var completionInfoIsPresented: Binding<Bool> {
        Binding(
            get: { selectedBadgeInfo != nil },
            set: { isPresented in
                if !isPresented {
                    selectedBadgeInfo = nil
                }
            }
        )
    }
}
