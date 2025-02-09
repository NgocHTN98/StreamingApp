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
            if RetryHTTPStatus.shouldRetry(response.statusCode) && retriesLeft > 0 {
                return try await self.sendRequestWithRetries(request: request, retriesLeft: retriesLeft - 1)
            } else {
                return (data, response)
            }
        } catch {
            throw error
        }
    }
}

enum RetryHTTPStatus: Int {
    case requestTimeout = 408 // The server took too long to respond. Retrying may help.
    case tooManyRequests = 429 // Indicates rate-limiting. Retry after the delay specified in the Retry-After header.
    case internalServerError = 500 // A server-side issue that may resolve itself. Retrying is optional.
    case badGateway = 502 // Suggests a temporary network issue or service stack disruption that may self-correct.
    case serviceUnavailable = 503 // May be due to temporary service outages or in-progress deployments.
    case gatewayTimeout = 504 // A downstream server (e.g., DNS) didn’t respond in time. Retrying may resolve the issue.

    static func shouldRetry(_ code: Int) -> Bool {
        return RetryHTTPStatus(rawValue: code) != nil
    }
}
