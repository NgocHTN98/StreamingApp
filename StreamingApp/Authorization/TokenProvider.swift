//
//  TokenProvider.swift
//  Streaming
//
//  Created by Nghia Dao on 6/2/25.
//
actor TokenProvider {
    private var accessToken: String?
    private var refreshToken: String?
    private let httpClient: HTTPClient

    // Singleton instance
    init(accessToken: String? = nil, refreshToken: String? = nil, httpClient: HTTPClient) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.httpClient = httpClient
    }

    /// Retrieves the current access token, throws an error if missing.
    func getAccessToken() throws -> String {
        guard let accessToken else {
            throw TokenError.tokenNotFound
        }
        return accessToken
    }

    /// Retrieves the current refresh token, throws an error if missing.
    func getRefreshToken() throws -> String {
        guard let refreshToken else {
            throw TokenError.refreshTokenNotFound
        }
        return refreshToken
    }

    /// Updates the access token.
    func setAccessToken(_ token: String) {
        self.accessToken = token
    }

    /// Validates if the token is still valid.
    func isTokenValid() -> Bool {
        // Placeholder logic - replace with actual validation
        return accessToken != nil
    }

    /// Refreshes the access token using the refresh token.
    func refreshToken() async throws {
        guard let refreshToken else {
            throw TokenError.refreshTokenNotFound
        }

        do {
//            let request = TokenRequest()
//            let newToken = try await httpClient.sendRequest(request)
//            self.accessToken = newToken
        } catch {
            throw TokenError.failedToRefresh
        }
    }

    // Token error handling
    enum TokenError: Error {
        case tokenNotFound
        case refreshTokenNotFound
        case failedToRefresh
    }
}

enum TokenError: Error {
    case tokenNotFound
    case refreshTokenNotFound
}
