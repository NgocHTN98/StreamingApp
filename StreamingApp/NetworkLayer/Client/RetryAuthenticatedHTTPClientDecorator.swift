//
//  RetryAuthenticatedHTTPClientDecorator.swift
//  StreamingApp
//
//  Created by Nghia Dao on 8/2/25.
//

import Foundation

class RetryAuthenticatedHTTPClientDecorator: HTTPClient {
    let client: HTTPClient
    let maxRetries: Int

    init(client: HTTPClient, maxRetries: Int) {
        self.client = client
        self.maxRetries = maxRetries
    }

    func sendRequest(_ request: HTTPRequest) async throws -> (Data, HTTPURLResponse) {
        return try await self.sendRequestWithRetries(request: request, retriesLeft: maxRetries)
    }

    private func sendRequestWithRetries(request: HTTPRequest, retriesLeft: Int) async throws -> (Data, HTTPURLResponse) {
        do {
            let (data, response) = try await client.sendRequest(request)
            let status = HTTPResponseStatus(rawValue: response.statusCode)

            if status.shouldRetry() && retriesLeft > 0 {
                return try await self.sendRequestWithRetries(request: request, retriesLeft: retriesLeft - 1)
            } else {
                return (data, response)
            }
        } catch {
            throw error
        }
    }
}
