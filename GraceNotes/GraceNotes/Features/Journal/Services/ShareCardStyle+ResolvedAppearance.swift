import SwiftUI

extension ShareCardStyle {
    /// `useLightCardPalette` is `true` for the classic light share card, `false` for the dark card theme (user toggle).

    func resolvedCardBackground(useLightCardPalette: Bool) -> some View {
        Group {
            if useLightCardPalette {
                cardBackgroundLayer()
            } else {
                darkCardBackgroundLayer()
            }
        }
    }

    func resolvedBodyInk(useLightCardPalette: Bool) -> Color {
        guard !useLightCardPalette else { return bodyInk }
        return Color(hex: 0xF2E8DE)
    }

    func resolvedSectionTitleInk(useLightCardPalette: Bool) -> Color {
        resolvedBodyInk(useLightCardPalette: useLightCardPalette)
    }

    func resolvedFooterInk(useLightCardPalette: Bool) -> Color {
        guard !useLightCardPalette else { return footerInk }
        return Color(hex: 0xC5B7A8)
    }

    func resolvedStubInk(useLightCardPalette: Bool) -> Color {
        resolvedFooterInk(useLightCardPalette: useLightCardPalette)
    }

    func resolvedSectionControlInk(useLightCardPalette: Bool) -> Color {
        resolvedFooterInk(useLightCardPalette: useLightCardPalette)
    }

    func resolvedSectionDividerColor(useLightCardPalette: Bool) -> Color {
        guard !useLightCardPalette else { return sectionDividerColor }
        return Color(hex: 0x3D3834)
    }

    func resolvedRedactionBarColor(useLightCardPalette: Bool) -> Color {
        guard !useLightCardPalette else { return redactionBarColor }
        return Color(hex: 0x4A423A)
    }

    func resolvedCardShadowColor(useLightCardPalette: Bool) -> Color {
        guard !useLightCardPalette else { return cardShadowColor }
        return Color.black.opacity(0.35)
    }

    func resolvedCompletionChipTextColor(useLightCardPalette: Bool) -> Color {
        guard !useLightCardPalette else { return completionChipTextColor }
        return Color(hex: 0xD4C4B6)
    }

    @ViewBuilder
    func resolvedCompletionChipBackground(useLightCardPalette: Bool) -> some View {
        if useLightCardPalette {
            completionChipBackgroundView()
        } else {
            darkCompletionChipBackground()
        }
    }

    @ViewBuilder
    private func darkCardBackgroundLayer() -> some View {
        switch self {
        case .paperWarm:
            Color(hex: 0x2A241F)
        case .editorialMist:
            Color(hex: 0x1C1C1C)
        case .sunriseGradient:
            LinearGradient(
                colors: [
                    Color(hex: 0x2A1F1A),
                    Color(hex: 0x302820),
                    Color(hex: 0x261C18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    @ViewBuilder
    private func darkCompletionChipBackground() -> some View {
        switch self {
        case .paperWarm:
            Color(hex: 0x3A322C)
        case .editorialMist:
            Color(hex: 0x333333)
        case .sunriseGradient:
            LinearGradient(
                colors: [Color(hex: 0x3D322C), Color(hex: 0x453D36)],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
}

private extension Color {
    init(hex: UInt) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(red: red, green: green, blue: blue)
    }
}
