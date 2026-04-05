import SwiftUI
import UIKit

/// Scale, opacity, and haptic feedback for tappable controls on Past and related drilldowns / theme flows.
struct PastTappablePressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.94 : 1.0)
            .opacity(configuration.isPressed ? 0.86 : 1.0)
            .animation(reduceMotion ? .none : .easeInOut(duration: 0.16), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { wasPressed, isPressed in
                guard isPressed, !wasPressed, !reduceMotion else { return }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
    }
}
