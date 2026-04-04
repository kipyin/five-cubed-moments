import XCTest
@testable import GraceNotes

final class ImportExportDetailFormattingTests: XCTestCase {
    func test_detailLooksLikeFileName_trueForExportedJsonNames() {
        let exportName = "grace-notes-export-20260101-120000.json"
        XCTAssertTrue(ImportExportTechnicalDetailFormatting.detailLooksLikeFileName(exportName))
        let scheduledName = "grace-notes-scheduled-20260101-120000.json"
        XCTAssertTrue(ImportExportTechnicalDetailFormatting.detailLooksLikeFileName(scheduledName))
    }

    func test_detailLooksLikeFileName_falseForLocalizedSentences() {
        let english = "Unable to reach the backup folder."
        XCTAssertFalse(ImportExportTechnicalDetailFormatting.detailLooksLikeFileName(english))
        XCTAssertFalse(ImportExportTechnicalDetailFormatting.detailLooksLikeFileName("备份失败"))
    }

    func test_detailLooksLikeFileName_falseWhenWhitespace() {
        XCTAssertFalse(ImportExportTechnicalDetailFormatting.detailLooksLikeFileName("my file.json"))
    }

    func test_detailLooksLikeFileName_falseForEmpty() {
        XCTAssertFalse(ImportExportTechnicalDetailFormatting.detailLooksLikeFileName(""))
        XCTAssertFalse(ImportExportTechnicalDetailFormatting.detailLooksLikeFileName("   "))
    }
}
