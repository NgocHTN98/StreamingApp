//
//  TokenProvider.swift
//  Streaming
//
//  Created by Nghia Dao on 6/2/25.
//

protocol TokenProvider {
    func getAccessToken() throws -> String
}

struct DefaultTokenProvider: TokenProvider {
    private var accessToken: String?
    private var refreshToken: String?

    func getAccessToken() throws -> String {
        return ""
    }
}
