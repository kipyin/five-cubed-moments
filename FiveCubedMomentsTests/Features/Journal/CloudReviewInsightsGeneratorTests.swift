import XCTest
@testable import FiveCubedMoments

final class CloudReviewInsightsGeneratorTests: XCTestCase {
    private var urlSession: URLSession!
    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        urlSession = URLSession(configuration: config)
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    }

    override func tearDown() {
        MockURLProtocol.mockResponse = nil
        super.tearDown()
    }

    func test_generateInsights_success_returnsCloudInsights() async throws {
        let generator = CloudReviewInsightsGenerator(
            apiKey: "test-key",
            urlSession: urlSession
        )
        let innerPayload: [String: Any] = [
            "narrativeSummary": "You kept a calm rhythm this week.",
            "resurfacingMessage": "You mentioned rest 3 times this week.",
            "continuityPrompt": "What can protect your rest tomorrow?",
            "recurringGratitudes": [["label": "Family", "count": 2]],
            "recurringNeeds": [["label": "Rest", "count": 3]],
            "recurringPeople": [["label": "Alex", "count": 2]]
        ]

        MockURLProtocol.mockResponse = { _ in
            let contentData: Data
            do {
                contentData = try JSONSerialization.data(withJSONObject: innerPayload)
            } catch {
                return (nil, nil, error)
            }
            let content = String(data: contentData, encoding: .utf8) ?? "{}"
            let response: [String: Any] = [
                "choices": [["message": ["content": content]]]
            ]
            let data: Data
            do {
                data = try JSONSerialization.data(withJSONObject: response)
            } catch {
                return (nil, nil, error)
            }
            let http = HTTPURLResponse(
                url: URL(string: "https://example.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (data, http, nil)
        }

        let insights = try await generator.generateInsights(
            from: [makeEntry(on: date(year: 2026, month: 3, day: 17))],
            referenceDate: date(year: 2026, month: 3, day: 18),
            calendar: calendar
        )

        XCTAssertEqual(insights.source, .cloudAI)
        XCTAssertEqual(insights.recurringNeeds.first?.label, "Rest")
        XCTAssertEqual(insights.recurringNeeds.first?.count, 3)
        XCTAssertEqual(insights.narrativeSummary, "You kept a calm rhythm this week.")
    }

    func test_generateInsights_invalidPayload_throws() async {
        let generator = CloudReviewInsightsGenerator(
            apiKey: "test-key",
            urlSession: urlSession
        )

        MockURLProtocol.mockResponse = { _ in
            let response: [String: Any] = [
                "choices": [["message": ["content": "not-json"]]]
            ]
            let data: Data
            do {
                data = try JSONSerialization.data(withJSONObject: response)
            } catch {
                return (nil, nil, error)
            }
            let http = HTTPURLResponse(
                url: URL(string: "https://example.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (data, http, nil)
        }

        do {
            _ = try await generator.generateInsights(
                from: [],
                referenceDate: date(year: 2026, month: 3, day: 18),
                calendar: calendar
            )
            XCTFail("Expected invalid payload error")
        } catch {
            XCTAssertTrue(true)
        }
    }

    func test_generateInsights_httpError_throws() async {
        let generator = CloudReviewInsightsGenerator(
            apiKey: "test-key",
            urlSession: urlSession
        )

        MockURLProtocol.mockResponse = { _ in
            let http = HTTPURLResponse(
                url: URL(string: "https://example.com")!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (Data(), http, nil)
        }

        do {
            _ = try await generator.generateInsights(
                from: [],
                referenceDate: date(year: 2026, month: 3, day: 18),
                calendar: calendar
            )
            XCTFail("Expected HTTP error")
        } catch {
            XCTAssertTrue(true)
        }
    }

    private func makeEntry(on date: Date) -> JournalEntry {
        JournalEntry(
            entryDate: date,
            gratitudes: [JournalItem(fullText: "Family", chipLabel: "Family")],
            needs: [JournalItem(fullText: "Rest", chipLabel: "Rest")],
            people: [JournalItem(fullText: "Alex", chipLabel: "Alex")]
        )
    }

    private func date(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.timeZone = calendar.timeZone
        return calendar.date(from: components)!
    }
}
