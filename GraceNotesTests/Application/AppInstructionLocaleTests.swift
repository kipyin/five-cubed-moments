import XCTest
@testable import GraceNotes

final class AppInstructionLocaleTests: XCTestCase {
    func test_isSimplifiedChineseUIIdentifier_simplifiedChineseVariants_match() {
        for id in ["zh-Hans", "zh-hans", "zh-Hans-CN", "ZH-HANS"] {
            XCTAssertTrue(
                AppInstructionLocale.isSimplifiedChineseUIIdentifier(id),
                "expected Simplified Chinese for \(id)"
            )
        }
    }

    func test_isSimplifiedChineseUIIdentifier_nonSimplifiedChinese_fallsBackToEnglish() {
        for id in ["zh-Hant", "zh-hant", "zh-Hant-TW", "zh", "en", ""] {
            XCTAssertFalse(
                AppInstructionLocale.isSimplifiedChineseUIIdentifier(id),
                "expected English instruction locale for \(id)"
            )
        }
    }
}
