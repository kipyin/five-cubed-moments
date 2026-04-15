import Foundation

/// Which natural language to use for cloud LLM *instructions* (not user-facing `Localizable` strings).
/// Matches Review chip insights: follow the app bundle’s active UI localization.
enum AppInstructionLocale: Equatable, Sendable {
    case english
    case simplifiedChinese

    /// `zh-Hans` → Simplified Chinese; otherwise English (default for future locales until prompts exist).
    static func preferred(bundle: Bundle = .main) -> AppInstructionLocale {
        guard let preferred = bundle.preferredLocalizations.first else {
            return .english
        }
        if isSimplifiedChineseUIIdentifier(preferred) {
            return .simplifiedChinese
        }
        return .english
    }

    /// Uses `Locale.Language` so legacy tags (`zh_CN`, `zh_Hans_CN`) and bare `zh` resolve like the system,
    /// instead of brittle `zh-hans` / `zh-hans-` string prefix checks that miss underscore forms.
    /// BCP 47 tags are case-insensitive; `Bundle` may return `zh-Hans` or `zh-hans`.
    /// - Note: Unit tests cover tag forms; production code should use ``preferred(bundle:)``.
    static func isSimplifiedChineseUIIdentifier(_ identifier: String) -> Bool {
        let language = Locale.Language(identifier: identifier)
        return language.languageCode == .chinese && language.script == simplifiedChineseScript
    }

    private static let simplifiedChineseScript = Locale.Script("Hans")
}
