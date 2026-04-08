import CoreGraphics

enum JournalStickyCompletionVisibility {
    // MARK: - iOS 18+ (scroll content offset)

    /// Reveal the toolbar chip when the user has scrolled the journal body down past `scrollRevealThreshold`.
    ///
    /// Uses the scroll view's ``ScrollGeometryProxy/contentOffset`` ``y`` (larger when content moves up).
    static func shouldShowBarIndicator(scrollContentOffsetY: CGFloat, scrollRevealThreshold: CGFloat) -> Bool {
        scrollContentOffsetY > scrollRevealThreshold
    }

    // MARK: - iOS 17 (header frame in scroll space)

    /// Reveal the toolbar chip when the completion header's top edge in the scroll view's named coordinate
    /// space sits above the visible origin by more than `scrollRevealThreshold` (i.e. `minY < -threshold`).
    ///
    /// Global header frame vs safe area was unreliable at rest: the header often sits above
    /// `safeAreaTop + small slack` while still fully on-screen (large title, varied layouts), which kept the
    /// bar chip visible constantly. Scroll-space `minY` decreases as the user scrolls down, which tracks
    /// “pulled the completion block upward” without depending on key-window reads.
    static func shouldShowBarIndicator(headerMinYInScrollSpace: CGFloat, scrollRevealThreshold: CGFloat) -> Bool {
        headerMinYInScrollSpace < -scrollRevealThreshold
    }
}
