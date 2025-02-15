//
//  TokenProvider.swift
//  Streaming
//
//  Created by Nghia Dao on 6/2/25.
//
protocol TokenProvider: Actor {
    func getAccessToken() throws -> String
    func getRefreshToken() throws -> String
    func setAccessToken(_ token: String)
    func refreshToken() async throws 
}

actor DefaultTokenProvider: TokenProvider {
    private var accessToken: String?
    private var refreshToken: String?
    private let serivce: TokenService

    init(accessToken: String? = nil, refreshToken: String? = nil, serivce: TokenService) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.serivce = serivce
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
        do {
            let results = try await serivce.refreshToken()
            self.accessToken = results.accessToken
            self.refreshToken = results.refreshToken
        } catch {
            throw TokenError.failedToRefresh
        }
    }

}

enum TokenError: Error {
    case tokenNotFound
    case refreshTokenNotFound
    case failedToRefresh
}
