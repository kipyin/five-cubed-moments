import Foundation

enum ImportExportTechnicalDetailFormatting {
    /// Returns true when ``detail`` should use monospace: app-style JSON filenames without spaces.
    /// Localized failure messages and sentences stay false so they can use Warm Paper meta fonts.
    static func detailLooksLikeFileName(_ detail: String) -> Bool {
        let trimmed = detail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        if trimmed.contains(where: { $0.isWhitespace }) { return false }
        return trimmed.lowercased().hasSuffix(".json")
    }
}
