import SwiftUI
import UIKit

enum JournalShareRenderer {
    /// Renders the share card to a bitmap.
    ///
    /// `ImageRenderer` proposes a size to the root view. If that size is effectively unbounded,
    /// flexible-width SwiftUI content can lay out poorly and `uiImage` may be nil or empty.
    /// Width must match `JournalShareCardView` export layout: inner `cardWidth` plus horizontal `padding`.
    @MainActor static func renderImage(from payload: ShareRenderPayload) -> UIImage? {
        let cardView = JournalShareCardView(payload: payload, onLineTap: nil)
        let renderer = ImageRenderer(content: cardView)
        renderer.proposedSize = ProposedViewSize(width: Self.proposedLayoutWidth, height: nil)
        renderer.scale = Self.recommendedPixelScale()
        guard let image = renderer.uiImage else { return nil }
        guard image.size.width > 0, image.size.height > 0 else { return nil }
        guard let cgImage = image.cgImage else { return nil }
        guard cgImage.width > 0, cgImage.height > 0 else { return nil }
        return image
    }

    /// Keep in sync with `JournalShareCardView` (`cardWidth` + twice `padding`).
    private static let cardContentWidth: CGFloat = 448
    private static let cardHorizontalPadding: CGFloat = 24
    private static var proposedLayoutWidth: CGFloat {
        cardContentWidth + cardHorizontalPadding * 2
    }

    /// `ImageRenderer` runs without hosting in a window; `UITraitCollection.current.displayScale` can be
    /// unset or 1× while the device screen is Retina. Prefer the foreground window scene scale (active or
    /// inactive — a presented sheet can leave the root scene inactive), then trait, then screen, then a
    /// safe default. Ignores background/unattached scenes so multi-window layouts do not pick an unrelated
    /// display’s scale.
    @MainActor
    private static func recommendedPixelScale() -> CGFloat {
        let traitScale = UITraitCollection.current.displayScale
        let sceneScale = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter {
                $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive
            }
            .map { $0.screen.scale }
            .max() ?? 0
        let screenScale = UIScreen.main.scale
        let best = max(
            traitScale > 0 ? traitScale : 0,
            sceneScale > 0 ? sceneScale : 0,
            screenScale > 0 ? screenScale : 0
        )
        guard best > 0 else { return 3 }
        return min(max(best, 1), 3)
    }
}
