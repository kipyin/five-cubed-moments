import CoreGraphics

enum JournalStickyCompletionVisibility {
    /// - Parameters:
    ///   - scrollContentMinY: Value from `JournalScrollOffsetPreferenceKey` / `journalScrollOffsetReader`
    ///     (negative when content has scrolled up).
    ///   - hideUntilScrolledPast: Positive distance (points) user must scroll before the bar indicator appears.
    static func shouldShowBarIndicator(scrollContentMinY: CGFloat, hideUntilScrolledPast: CGFloat) -> Bool {
        scrollContentMinY < -hideUntilScrolledPast
    }
}
