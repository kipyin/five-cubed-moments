import XCTest
@testable import GraceNotes

final class OnDeviceHybridSummarizerTests: XCTestCase {
    private let sut = DeterministicChipLabelSummarizer()

    func test_summarize_longEnglishSentence_returnsFirstFiveWords() async throws {
        let input = "I need clearer priorities and fewer context switches"
        let result = try await sut.summarize(input, section: .need)

        XCTAssertEqual(result.label, "I need cle")
        XCTAssertTrue(result.isTruncated)
    }

    func test_summarize_chineseSentence_returnsFirstFiveHanCharacters() async throws {
        let input = "今天我感恩有好朋友陪伴"
        let result = try await sut.summarize(input, section: .gratitude)

        XCTAssertEqual(result.label, "今天我感恩")
        XCTAssertTrue(result.isTruncated)
    }

    func test_summarize_emptyInput_returnsEmptyLabel() async throws {
        let result = try await sut.summarize("   ", section: .gratitude)

        XCTAssertEqual(result.label, "")
        XCTAssertFalse(result.isTruncated)
    }

    func test_summarize_personSection_keepsLatinNameInMixedLanguageInput() async throws {
        let input = "为 Amy 祷告平安"
        let result = try await sut.summarize(input, section: .person)

        XCTAssertTrue(result.label.contains("Amy"))
        XCTAssertTrue(result.isTruncated)
    }

    func test_summarize_needSection_keepsShortAcronymFromNLP() async throws {
        let result = try await sut.summarize(
            "Need to reserve one focused block for AI project planning today",
            section: .need
        )

        XCTAssertEqual(result.label, "Need to re")
        XCTAssertTrue(result.isTruncated)
    }
}
