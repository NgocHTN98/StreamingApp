//
//  AuthenticatedHTTPClientDecoratorTestsHelper.swift
//  StreamingApp
//
//  Created by Nghia Dao on 15/2/25.
//
import XCTest
@testable import StreamingApp

class MockTokenService: TokenService {
    var mockToken: Token?
    var mockError: RequestError?

    func setMockToken(_ token: Token) {
        self.mockToken = token
        self.mockError = nil // Ensure no error is set when using a valid token
    }

    func setMockError(_ error: RequestError) {
        self.mockError = error
        self.mockToken = nil // Ensure no token is set when simulating an error
    }

    func refreshToken() async throws -> Token {
        if let error = mockError {
            throw error
        }
        guard let token = mockToken else {
            throw URLError(.userAuthenticationRequired) // Default failure case
        }
        return token
    }
}

class MockHTTPClient: HTTPClient {
    var responses: [(Data, HTTPURLResponse)] = []
    var requests: [HTTPRequest] = []
    var shouldTimeout = false

    func sendRequest(_ request: HTTPRequest) async throws -> (Data, HTTPURLResponse) {
        requests.append(request)

        if shouldTimeout {
            try await Task.sleep(nanoseconds: 3_000_000_000) // Simulate 3 seconds delay
            throw URLError(.timedOut) // Simulate timeout error
        }

        if responses.isEmpty {
            throw URLError(.badServerResponse) // Default failure case
        }

        return responses.removeFirst()
    }
}

struct MockHTTPRequest: HTTPRequest {
    var host: String
    var scheme: String
    var path: String
    var method: HTTPMethod
    var headers: [String: String]
    var params: [String: Any]

    init(
        host: String = "Mock",
        scheme: String = "https",
        path: String = "/example",
        method: HTTPMethod = .GET,
        headers: [String: String] = [:],
        params: [String: Any] = [:]
    ) {
        self.host = host
        self.scheme = scheme
        self.path = path
        self.method = method
        self.headers = headers
        self.params = params
    }
}

actor MockTokenProvider: TokenProvider {
    func getAccessToken() throws -> String {
        return accessToken ?? ""
    }

    func getRefreshToken() throws -> String {
        return refreshToken ?? ""
    }

    func setAccessToken(_ token: String) {
        self.accessToken = token
    }

    var accessToken: String?
    var refreshToken: String?
    var refreshedToken: String?
    var shouldFailRefresh = false

    init(accessToken: String? = nil, refreshToken: String? = nil, refreshedToken: String? = nil) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.refreshedToken = refreshedToken
    }

    func isTokenValid() async -> Bool {
        return accessToken != nil
    }

    func refreshToken() async throws {
        if shouldFailRefresh {
            throw TokenError.failedToRefresh
        }
        accessToken = refreshedToken
        refreshToken = refreshedToken
    }
}
