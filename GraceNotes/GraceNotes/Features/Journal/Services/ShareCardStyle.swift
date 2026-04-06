import SwiftUI

/// Named presets for the exported share card bitmap (maps to `AppTheme` tokens).
///
/// Three typographic personas: Grace Notes default (warm serif journal), editorial magazine
/// (Outfit headlines + IBM Plex Serif body), and embellished (Spectral on the sunrise gradient).
enum ShareCardStyle: String, CaseIterable, Identifiable, Sendable {
    case paperWarm
    case editorialMist
    case sunriseGradient

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .paperWarm:
            String(localized: "sharing.style.paperWarm")
        case .editorialMist:
            String(localized: "sharing.style.editorialMist")
        case .sunriseGradient:
            String(localized: "sharing.style.sunriseGradient")
        }
    }

    // MARK: - Background

    @ViewBuilder
    func cardBackgroundLayer() -> some View {
        switch self {
        case .paperWarm:
            AppTheme.paper
        case .editorialMist:
            AppTheme.background
        case .sunriseGradient:
            LinearGradient(
                colors: [AppTheme.fullFifteenBackgroundStart, AppTheme.fullFifteenBackgroundEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    /// Primary ink for body copy (list items and prose).
    var bodyInk: Color {
        switch self {
        case .paperWarm, .editorialMist:
            AppTheme.textPrimary
        case .sunriseGradient:
            // Slightly darker than `fullFifteenText` for contrast on warm gradient stops (WCAG AA).
            Color(red: 0.39, green: 0.25, blue: 0.15)
        }
    }

    /// Section titles (below the date row).
    var sectionTitleInk: Color {
        switch self {
        case .paperWarm:
            AppTheme.textPrimary
        case .editorialMist:
            AppTheme.textMuted
        case .sunriseGradient:
            Color(red: 0.39, green: 0.25, blue: 0.15)
        }
    }

    /// Date row.
    var dateFont: Font {
        switch self {
        case .paperWarm:
            AppTheme.warmPaperHeader
        case .editorialMist:
            Font.custom("Outfit-SemiBold", size: 20, relativeTo: .title3)
        case .sunriseGradient:
            Font.custom("Spectral-SemiBold", size: 22, relativeTo: .title3)
        }
    }

    /// Gratitudes / needs / people / reading / reflections headers.
    var sectionTitleFont: Font {
        switch self {
        case .paperWarm:
            Font.custom("PlayfairDisplay-Regular", size: 17, relativeTo: .headline).weight(.semibold)
        case .editorialMist:
            AppTheme.outfitSemiboldSubheadline
        case .sunriseGradient:
            Font.custom("Spectral-SemiBold", size: 18, relativeTo: .headline)
        }
    }

    /// Body lines (list items and prose).
    var bodyFont: Font {
        switch self {
        case .paperWarm:
            AppTheme.warmPaperBody
        case .editorialMist:
            Font.custom("IBMPlexSerif-Regular", size: 17, relativeTo: .body)
        case .sunriseGradient:
            Font.custom("Spectral-Regular", size: 17, relativeTo: .body)
        }
    }

    /// Footer watermark, stub hints, and secondary metadata (composer may override footer font).
    var metaFont: Font {
        switch self {
        case .paperWarm:
            AppTheme.warmPaperMeta
        case .editorialMist:
            Font.custom("IBMPlexSerif-Regular", size: 15, relativeTo: .footnote)
        case .sunriseGradient:
            Font.custom("Spectral-Regular", size: 15, relativeTo: .footnote)
        }
    }

    var footerInk: Color {
        switch self {
        case .paperWarm:
            AppTheme.textPrimary.opacity(0.55)
        case .editorialMist:
            AppTheme.textMuted.opacity(0.72)
        case .sunriseGradient:
            AppTheme.fullFifteenMetaText.opacity(0.92)
        }
    }

    var stubInk: Color {
        switch self {
        case .paperWarm, .editorialMist:
            AppTheme.textMuted
        case .sunriseGradient:
            AppTheme.fullFifteenMetaText.opacity(0.95)
        }
    }

    /// Muted ink for section include/exclude control (xmark / plus).
    var sectionControlInk: Color {
        switch self {
        case .paperWarm, .editorialMist:
            AppTheme.textMuted
        case .sunriseGradient:
            AppTheme.fullFifteenMetaText.opacity(0.82)
        }
    }

    // MARK: - Chrome

    var showsTopAccentRule: Bool {
        self == .paperWarm
    }

    var showsAccentRuleUnderDate: Bool {
        self == .sunriseGradient
    }

    var showsSectionDividers: Bool {
        self == .editorialMist
    }

    var showsPaperShadow: Bool {
        self == .paperWarm
    }

    func topAccentOpacity() -> Double {
        switch self {
        case .paperWarm: 0.85
        case .sunriseGradient: 0.9
        case .editorialMist: 0.85
        }
    }

    func topAccentHeight() -> CGFloat {
        switch self {
        case .sunriseGradient: 6
        default: 4
        }
    }
}
