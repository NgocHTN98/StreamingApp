//
//  AuthenticatedHTTPClientDecoratorTests.swift
//  StreamingAppTests
//
//  Created by Nghia Dao on 9/2/25.
//

import XCTest
@testable import StreamingApp

final class AuthenticatedHTTPClientDecoratorTests: XCTestCase {

    var mockClient: MockHTTPClient!
    var mockTokenService: MockTokenService!
    var mockTokenProvider: TokenProvider!
    var sut: AuthenticatedHTTPClientDecorator!

    let initToken = "init_Token"
    let refreshedToken = "refreshed_Token"
    let refreshToken = "refresh_Token"

    override func setUp() {
        super.setUp()
        mockClient = MockHTTPClient()
        mockTokenService = MockTokenService()
        mockTokenProvider = MockTokenProvider(
            accessToken: initToken,
            refreshToken: refreshToken,
            refreshedToken: refreshedToken
        )
        sut = AuthenticatedHTTPClientDecorator(
            client: mockClient,
            tokenProvider: mockTokenProvider
        )
    }

    /// Test that the request is signed with an access token
    func test_sendRequest_signsRequestWithToken() async throws {
        let request = MockHTTPRequest()
        let httpRequest = try request.createURLRequest()
        mockClient.responses = [(Data(), HTTPURLResponse(url: httpRequest.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!)]

        _ = try await sut.sendRequest(request)

        XCTAssertEqual(mockClient.requests.count, 1)
        XCTAssertEqual(mockClient.requests.first?.headers["Authorization"], initToken)
    }

    /// Test that it retries after getting an unauthorized response
    func test_sendRequest_retriesAfterTokenRefresh() async throws {
        let request = MockHTTPRequest()
        let httpRequest = try request.createURLRequest()
        let unauthorizedResponse = HTTPURLResponse(url: httpRequest.url!, statusCode: 401, httpVersion: nil, headerFields: nil)!
        let successResponse = HTTPURLResponse(url: httpRequest.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!

        mockClient.responses = [
            (Data(), unauthorizedResponse), // First attempt fails
            (Data(), successResponse)       // Retry succeeds
        ]

        _ = try await sut.sendRequest(request)

        XCTAssertEqual(mockClient.requests.count, 2)
        XCTAssertEqual(mockClient.requests.first?.headers["Authorization"], initToken)
        XCTAssertEqual(mockClient.requests.last?.headers["Authorization"], refreshedToken)
    }

    /// Test that it does not retry when the response is not unauthorized
    func test_sendRequest_doesNotRetryForOtherErrors() async throws {
        let request = MockHTTPRequest()
        let httpRequest = try request.createURLRequest()
        let forbiddenResponse = HTTPURLResponse(url: httpRequest.url!, statusCode: 403, httpVersion: nil, headerFields: nil)!

        mockClient.responses = [
            (Data(), forbiddenResponse)
        ]

        _ = try? await sut.sendRequest(request)

        XCTAssertEqual(mockClient.requests.count, 1)
        XCTAssertEqual(mockClient.requests.last?.headers["Authorization"], initToken)
    }

    /// Test that it propagates client errors
    func test_sendRequest_propagatesClientError() async {
        let request = MockHTTPRequest()
        mockClient.responses = []

        do {
            _ = try await sut.sendRequest(request)
            XCTFail("Expected an error but got success")
        } catch {
            XCTAssertTrue(error is URLError)
        }
    }

    func test_requestTimeout_throwsError() async {
         // Simulate timeout scenario
         mockClient.shouldTimeout = true

         let request = MockHTTPRequest()

         do {
             _ = try await sut.sendRequest(request)
             XCTFail("Expected request to fail with timeout error")
         } catch {
             XCTAssertEqual((error as? URLError)?.code, .timedOut, "Expected URLError.timedOut, but got \(error)")
         }
     }
}
