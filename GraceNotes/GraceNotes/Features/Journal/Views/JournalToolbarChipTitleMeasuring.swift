import UIKit

enum JournalToolbarChipTitleMeasuring {
    /// Matches ``AppTheme/warmPaperToolbarChipTitle`` (16pt Source Serif semibold, `relativeTo: .body`).
    static func toolbarChipTitleUIFont(forTextStyle textStyle: UIFont.TextStyle = .body) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: textStyle)
        let size: CGFloat = 16
        guard let regular = UIFont(name: "SourceSerif4Roman-Regular", size: size) else {
            return metrics.scaledFont(for: UIFont.preferredFont(forTextStyle: textStyle))
        }
        let semiboldDescriptor = regular.fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.traits: [
                UIFontDescriptor.TraitKey.weight: UIFont.Weight.semibold
            ]
        ])
        let semibold = UIFont(descriptor: semiboldDescriptor, size: size)
        return metrics.scaledFont(for: semibold)
    }

    static func singleLineTextWidth(_ text: String, font: UIFont) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let size = (text as NSString).size(withAttributes: attributes)
        return ceil(size.width)
    }

    /// `+2` pt base slack so SwiftUI layout does not underflow UIKit measurement at fractional pixels.
    /// CJK uses system fallback fonts in SwiftUI that can exceed UIKit single-font bounds — add extra trailing room.
    static func measuredToolbarChipTitleWidth(for title: String, locale: Locale = .current) -> CGFloat {
        let base = singleLineTextWidth(title, font: toolbarChipTitleUIFont(forTextStyle: .body)) + 2
        switch locale.language.languageCode?.identifier {
        case "zh", "ja", "ko":
            return base + 14
        default:
            return base
        }
    }
}
