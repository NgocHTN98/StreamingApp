//
//  AuthenticatedHTTPClientDecorator.swift
//  Streaming
//
//  Created by Nghia Dao on 6/2/25.
//
import Foundation

class AuthenticatedHTTPClientDecorator: HTTPClient {
    let client: HTTPClient
    let tokenProvider: TokenProvider

    init(client: HTTPClient, tokenProvider: TokenProvider) {
        self.client = client
        self.tokenProvider = tokenProvider
    }

    func sendRequest(_ request: HTTPRequest) async throws -> (Data, HTTPURLResponse) {
        return try await sendRequestWithRefresh(request: request)
    }

    private func sendRequestWithRefresh(request: HTTPRequest) async throws -> (Data, HTTPURLResponse) {
        do {
            var signedRequest = await createSignedRequest(from: request)
            let (data, response) = try await client.sendRequest(signedRequest)

            let status = HTTPResponseStatus(rawValue: response.statusCode) 
            if status.shouldRefresh() {
                // 🔄 Wait for the refresh token before retrying
                try await tokenProvider.refreshToken()
                signedRequest = await createSignedRequest(from: request)

                return try await client.sendRequest(signedRequest)
            } else {
                return (data, response)
            }
        } catch {
            throw error
        }
    }

    private func createSignedRequest(from request: HTTPRequest) async -> HTTPRequest {
        var signedRequest = request
         // Set the Authorization header using the access token
        signedRequest.headers["Authorization"] = await (try? tokenProvider.getAccessToken()) ?? ""

        return signedRequest
    }

}
