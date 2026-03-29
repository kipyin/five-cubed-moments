import SwiftUI

/// Shared completion status pill for the journal date section header.
struct JournalCompletionPill: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.todayJournalPalette) private var palette

    let completionLevel: JournalCompletionLevel
    let celebratingLevel: JournalCompletionLevel?
    var morphSource: Bool = false
    var morphNamespace: Namespace.ID?
    var morphAccentColor: Color = .clear
    var morphBloomProgress: CGFloat = 0

    var body: some View {
        pillLabel
            .font(AppTheme.warmPaperMetaEmphasis)
            .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 2)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, AppTheme.spacingRegular)
            .padding(.vertical, AppTheme.spacingTight)
            .frame(minHeight: 44)
            .background(pillBackground)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                    .stroke(borderColor(for: completionLevel), lineWidth: 1)
            )
            .scaleEffect(scaleFactor(for: completionLevel, isCelebrating: isCelebrating))
            .shadow(
                color: shadowColor(for: completionLevel, isCelebrating: isCelebrating),
                radius: shadowRadius(for: completionLevel, isCelebrating: isCelebrating),
                x: 0,
                y: isCelebrating && !reduceTransparency ? 2 : 0
            )
            .animation(
                reduceMotion ? nil : AppTheme.celebrationPulseAnimation(for: completionLevel),
                value: isCelebrating
            )
            .overlay {
                if morphSource {
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                        .stroke(
                            morphAccentColor.opacity(0.32 * morphBloomProgress),
                            lineWidth: 1.6
                        )
                        .scaleEffect(1.02 + (0.08 * (1 - morphBloomProgress)))
                }
            }
            .opacity(morphSource && !reduceMotion ? 0.92 : 1)
            .accessibilityElement(children: .combine)
    }

    private var isCelebrating: Bool {
        celebratingLevel == completionLevel && completionLevel != .empty
    }

    @ViewBuilder
    private var pillLabel: some View {
        switch completionLevel {
        case .empty:
            Text(String(localized: "Empty"))
                .foregroundStyle(palette.textMuted)
        case .started:
            Text(String(localized: "Started"))
                .foregroundStyle(palette.quickCheckInText)
        case .growing:
            Text(String(localized: "Growing"))
                .foregroundStyle(palette.standardText)
        case .balanced:
            Text(String(localized: "Balanced"))
                .foregroundStyle(palette.standardText)
        case .full:
            Text(String(localized: "Full"))
                .foregroundStyle(palette.fullText)
        }
    }

    @ViewBuilder
    private var pillBackground: some View {
        let base = RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
            .fill(backgroundFill(for: completionLevel))

        if let morphNamespace, morphSource, !reduceMotion {
            base.matchedGeometryEffect(
                id: "completionInfoMorphSurface",
                in: morphNamespace,
                properties: .frame,
                anchor: .topLeading,
                isSource: true
            )
        } else {
            base
        }
    }

    private func backgroundFill(for level: JournalCompletionLevel) -> AnyShapeStyle {
        switch level {
        case .empty:
            return AnyShapeStyle(palette.background)
        case .started:
            return AnyShapeStyle(palette.quickCheckInBackground)
        case .growing, .balanced:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [palette.standardBackgroundStart, palette.standardBackgroundEnd],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .full:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [palette.fullBackgroundStart, palette.fullBackgroundEnd],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }

    private func borderColor(for level: JournalCompletionLevel) -> Color {
        switch level {
        case .empty:
            return palette.border
        case .started:
            return palette.quickCheckInBorder
        case .growing, .balanced:
            return palette.standardBorder
        case .full:
            return palette.fullBorder
        }
    }

    private func scaleFactor(for level: JournalCompletionLevel, isCelebrating: Bool) -> CGFloat {
        guard isCelebrating, !reduceMotion else { return 1.0 }
        switch level {
        case .empty:
            return 1.0
        case .started:
            return 1.008
        case .growing:
            return 1.01
        case .balanced:
            return 1.015
        case .full:
            return 1.02
        }
    }

    private func shadowColor(for level: JournalCompletionLevel, isCelebrating: Bool) -> Color {
        guard isCelebrating, !reduceTransparency else { return .clear }
        switch level {
        case .empty:
            return .clear
        case .started:
            return palette.quickCheckInGlow.opacity(0.25)
        case .growing, .balanced:
            return palette.standardGlow.opacity(0.4)
        case .full:
            return palette.fullGlow.opacity(0.48)
        }
    }

    private func shadowRadius(for level: JournalCompletionLevel, isCelebrating: Bool) -> CGFloat {
        guard isCelebrating, !reduceTransparency else { return 0 }
        switch level {
        case .empty:
            return 0
        case .started:
            return 4
        case .growing:
            return 6
        case .balanced:
            return 8
        case .full:
            return 11
        }
    }
}
