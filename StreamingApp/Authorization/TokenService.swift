//
//  TokenService.swift
//  StreamingApp
//
//  Created by Nghia Dao on 8/2/25.
//

import Foundation

protocol TokenService {
    func refreshToken() async throws -> Token
}

final class DefaultTokenService: TokenService {
    let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func refreshToken() async throws -> Token {
        let request = TokenRequest()
        do {
            let (data, response): (Data, HTTPURLResponse) = try await client.sendRequest(request)
            return try TokenHTTPRequestMapper.map(data: data, response: response)
        } catch {
            throw error
        }
    }
}

struct TokenHTTPRequestMapper {
    static func map(data: Data, response: HTTPURLResponse) throws -> Token {
        switch response.statusCode {
        case 200...299:
            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(Token.self, from: data)
            return decodedResponse
        default:
            throw RequestError.unexpectedStatusCode(description: "Status Code: \(response.statusCode)")
        }
    }

}
