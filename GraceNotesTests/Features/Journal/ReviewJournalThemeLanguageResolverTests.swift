import XCTest
@testable import GraceNotes

final class ReviewJournalThemeLanguageResolverTests: XCTestCase {
    func test_resolvedDisplayLocale_shortCorpus_fallsBackToEnglish() {
        let resolver = ReviewJournalThemeLanguageResolver(
            minimumMeaningfulGraphemes: 200,
            confidenceThreshold: 0.55
        )
        let locale = resolver.resolvedDisplayLocale(forJournalCorpus: String(repeating: "休", count: 10))
        XCTAssertEqual(locale.identifier, "en")
    }

    func test_resolvedDisplayLocale_highThreshold_fallsBackToScriptTieBreak() {
        let resolver = ReviewJournalThemeLanguageResolver(
            minimumMeaningfulGraphemes: 8,
            confidenceThreshold: 1.0
        )
        let corpus = String(repeating: "休息", count: 20)
        let locale = resolver.resolvedDisplayLocale(forJournalCorpus: corpus)
        XCTAssertEqual(locale.identifier, "zh-Hans")
    }

    func test_resolvedDisplayLocale_latinWinsTieBreakWhenNoStrongHypothesis() {
        let resolver = ReviewJournalThemeLanguageResolver(
            minimumMeaningfulGraphemes: 8,
            confidenceThreshold: 1.0
        )
        let corpus = String(repeating: "abcde ", count: 30)
        let locale = resolver.resolvedDisplayLocale(forJournalCorpus: corpus)
        XCTAssertEqual(locale.identifier, "en")
    }
}
