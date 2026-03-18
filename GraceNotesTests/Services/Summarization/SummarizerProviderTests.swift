import XCTest
@testable import GraceNotes

final class SummarizerProviderTests: XCTestCase {
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: SummarizerProvider.useCloudUserDefaultsKey)
        super.tearDown()
    }

    func test_currentSummarizer_withFixedSummarizer_returnsFixedSummarizer() {
        let mock = MockSummarizer()
        let provider = SummarizerProvider(fixedSummarizer: mock)

        let result = provider.currentSummarizer()

        XCTAssertTrue(result is MockSummarizer)
    }

    func test_currentSummarizer_withoutFixedSummarizer_UserDefaultsKeyAbsent_returnsDeterministicFallback() {
        UserDefaults.standard.removeObject(forKey: SummarizerProvider.useCloudUserDefaultsKey)
        let provider = SummarizerProvider()

        let result = provider.currentSummarizer()

        XCTAssertTrue(result is DeterministicChipLabelSummarizer)
    }

    func test_currentSummarizer_withoutFixedSummarizer_UserDefaultsFalse_returnsDeterministicFallback() {
        UserDefaults.standard.set(false, forKey: SummarizerProvider.useCloudUserDefaultsKey)
        let provider = SummarizerProvider()

        let result = provider.currentSummarizer()

        XCTAssertTrue(result is DeterministicChipLabelSummarizer)
    }

    func test_currentSummarizer_UserDefaultsTrue_placeholderKey_returnsDeterministicFallback() {
        UserDefaults.standard.set(true, forKey: SummarizerProvider.useCloudUserDefaultsKey)
        let provider = SummarizerProvider()

        let result = provider.currentSummarizer()

        XCTAssertTrue(
            result is DeterministicChipLabelSummarizer,
            "With placeholder API key, provider should fall back to deterministic summarizer"
        )
    }
}
