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
        var signedRequest = request
         // Set the Authorization header using the access token
        signedRequest.headers["Authorization"] = await (try? tokenProvider.getAccessToken()) ?? ""

         // Send the request using the client and return the response data
         return try await client.sendRequest(signedRequest)
    }
}
