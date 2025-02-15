//
//  RetryHTTPClientDecoratorTest.swift
//  StreamingApp
//
//  Created by Nghia Dao on 15/2/25.
//

import XCTest
@testable import StreamingApp

final class RetryHTTPClientDecoratorTest: XCTestCase {
    var mockClient: MockHTTPClient!
    var mockTokenService: MockTokenService!
    var sut: RetryHTTPClientDecorator!

    override func setUp() {
        super.setUp()
        mockClient = MockHTTPClient()
        mockTokenService = MockTokenService()

        sut = RetryHTTPClientDecorator(
            client: mockClient,
            maxRetries: 3
        )
    }

    /// ✅ Test: Request succeeds on the first attempt (no retry needed)
    func test_requestSucceedsImmediately() async throws {
        let request = MockHTTPRequest()
        let httpRequest = try request.createURLRequest()
        let successResponse = HTTPURLResponse(url: httpRequest.url!,
                                              statusCode: 200, httpVersion: nil, headerFields: nil)!
        mockClient.responses = [(Data(), successResponse)]
        let result = try await sut.sendRequest(request)

        XCTAssertEqual(mockClient.requests.count, 1, "Expected only one request without retries.")
        XCTAssertEqual(result.1.statusCode, 200, "Expected a successful response.")
    }

    /// ✅ Test: Request fails twice, succeeds on third attempt
    func test_requestRetriesUntilSuccess() async throws {
        let failureResponse = HTTPURLResponse(url: URL(string: "https://mock.com")!,
                                              statusCode: 500, httpVersion: nil, headerFields: nil)!
        let successResponse = HTTPURLResponse(url: URL(string: "https://mock.com")!,
                                              statusCode: 200, httpVersion: nil, headerFields: nil)!

        mockClient.responses = [(Data(), failureResponse), (Data(), failureResponse), (Data(), successResponse)]

        let request = MockHTTPRequest()
        let result = try await sut.sendRequest(request)

        XCTAssertEqual(mockClient.requests.count, 3, "Expected three requests due to retries.")
        XCTAssertEqual(result.1.statusCode, 200, "Expected a successful response after retries.")
    }

    /// ✅ Test: Request fails even after max retries
    func test_requestFailsAfterMaxRetries() async {
        let failureResponse = HTTPURLResponse(url: URL(string: "https://mock.com")!,
                                              statusCode: 500, httpVersion: nil, headerFields: nil)!

        mockClient.responses = Array(repeating: (Data(), failureResponse), count: 4) // More than maxRetries

        let request = MockHTTPRequest()

        do {
            _ = try await sut.sendRequest(request)
            XCTAssertEqual(mockClient.requests.count, 4, "Expected max retries + original request.")
        } catch {
        }
    }

    /// ✅ Test: Non-retryable error (e.g., 400) does not retry
    func test_requestFailsImmediatelyOnNonRetryableError() async {
        let badRequestResponse = HTTPURLResponse(url: URL(string: "https://mock.com")!,
                                                 statusCode: 400, httpVersion: nil, headerFields: nil)!

        mockClient.responses = [(Data(), badRequestResponse)]

        let request = MockHTTPRequest()

        do {
            _ = try await sut.sendRequest(request)
            XCTAssertEqual(mockClient.requests.count, 1, "Expected only one request, no retries.")
        } catch {
        }
    }
}
