//
//  HTTPRequest.swift
//  Streaming
//
//  Created by Nghia Dao on 6/2/25.
//

import Foundation

protocol HTTPRequest {
    var host: String { get }
    var scheme: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get set}
    var params: [String: Any] { get }
}

extension HTTPRequest {
    var host: String {
        return AppConfig.host
    }

    func createURLRequest() throws -> URLRequest {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path

        guard let url = components.url else {
            throw RequestError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue

        if !headers.isEmpty {
            urlRequest.allHTTPHeaderFields = headers
        }
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if !params.isEmpty {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params)
        }

        return urlRequest
    }
}
