import CoreGraphics

enum JournalStickyCompletionVisibility {
    /// Whether the completion header has scrolled up into the navigation chrome far enough to show the bar chip.
    ///
    /// Uses the header's **global** min Y vs `safeAreaTopInset` because scroll-view named coordinate spaces
    /// and large titles are inconsistent across OS versions; global + safe area tracks “under the nav” reliably.
    ///
    /// - Parameters:
    ///   - completionHeaderTopGlobalY: Top edge of `DateSectionView` in global coordinates (smaller = higher on screen).
    ///   - safeAreaTopInset: `safeAreaInsets.top` for the journal screen.
    ///   - headerTopPastToolbarSlackPoints: Extra points below the safe-area top to treat as “past” the toolbar
    ///     (covers standard / large navigation chrome).
    static func shouldShowBarIndicator(
        completionHeaderTopGlobalY: CGFloat,
        safeAreaTopInset: CGFloat,
        headerTopPastToolbarSlackPoints: CGFloat
    ) -> Bool {
        completionHeaderTopGlobalY < safeAreaTopInset + headerTopPastToolbarSlackPoints
    }
}
