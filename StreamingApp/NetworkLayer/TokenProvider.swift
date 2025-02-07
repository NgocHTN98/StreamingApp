//
//  TokenProvider.swift
//  Streaming
//
//  Created by Nghia Dao on 6/2/25.
//
actor TokenProvider{
    private var accessToken: String?
    private var refreshToken: String?

    func getAccessToken() throws -> String {
        guard let accessToken else {
            throw TokenError.TokenNotFound
        }
        return accessToken
    }

    func getRefreshToken() throws -> String {
        guard let refreshToken else {
            throw TokenError.TokenNotFound
        }
        return refreshToken
    }


    func setAccessToken(_ token: String) {
        self.accessToken = token
    }
}

enum TokenError: Error {
    case TokenNotFound
    case RefreshTokenNotFound
}


