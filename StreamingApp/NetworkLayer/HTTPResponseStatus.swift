//
//  HTTPResponseStatus.swift
//  StreamingApp
//
//  Created by Nghia Dao on 15/2/25.
//

enum HTTPResponseStatus: Int {

    case success = 200
    // MARK: retry case
    case requestTimeout = 408 // The server took too long to respond. Retrying may help.
    case tooManyRequests = 429 // Indicates rate-limiting. Retry after the delay specified in the Retry-After header.
    case internalServerError = 500 // A server-side issue that may resolve itself. Retrying is optional.
    case badGateway = 502 // Suggests a temporary network issue or service stack disruption that may self-correct.
    case serviceUnavailable = 503 // May be due to temporary service outages or in-progress deployments.
    case gatewayTimeout = 504 // A downstream server (e.g., DNS) didn’t respond in time. Retrying may resolve the issue.

    // MARK: refresh Case
    case unauthorized = 401 // Unauthorized

    // MARK: Expired Token
    case expiredToken = 505

    // MARK: unknown error
    case unknown = -1

    init?(rawValue: Int) {
        switch rawValue {
        case 200...299:
            self = .success
        default:
            self = HTTPResponseStatus(rawValue: rawValue) ?? .unknown
        }
    }

    func shouldRetry() -> Bool {
        switch self {
        case   .requestTimeout,
                .tooManyRequests,
                .internalServerError,
                .badGateway,
                .serviceUnavailable,
                .gatewayTimeout:
            return true
        default:
            return false
        }
    }

    func shouldRefresh() -> Bool {
        switch self {
        case  .unauthorized:
            return true
        default:
            return false
        }
    }
}
