//
//  RequestError.swift
//  Streaming
//
//  Created by Nghia Dao on 6/2/25.
//

enum RequestError: Error {
    case decode
    case invalidURL
    case noResponse
    case unauthorized
    case unexpectedStatusCode(description: String)
    case failed(description: String)
    case tokenExpired
    case unknown

    var customMessage: String {
        switch self {
        case .decode:
            return "Decode error"
        case .unauthorized:
            return "Session expired"
        default:
            return "Unknown error"
        }
    }
}
