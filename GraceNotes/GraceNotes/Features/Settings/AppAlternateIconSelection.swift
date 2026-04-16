import UIKit

/// Names the alternate app icon set in the asset catalog (`ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES`).
@MainActor
enum AppAlternateIconSelection {
    /// Matches `AppIconLegacy.appiconset` and the generated `CFBundleAlternateIcons` entry.
    static let legacyAssetCatalogName = "AppIconLegacy"

    enum Choice: String, CaseIterable, Identifiable {
        case liquidGlass
        case legacy

        var id: String { rawValue }
    }

    static var supportsAlternateIcons: Bool {
        UIApplication.shared.supportsAlternateIcons
    }

    static func currentChoice() -> Choice {
        if UIApplication.shared.alternateIconName == legacyAssetCatalogName {
            return .legacy
        }
        return .liquidGlass
    }

    static func setChoice(_ choice: Choice, completion: @escaping (Error?) -> Void) {
        let name: String? = choice == .legacy ? legacyAssetCatalogName : nil
        UIApplication.shared.setAlternateIconName(name, completionHandler: completion)
    }
}
