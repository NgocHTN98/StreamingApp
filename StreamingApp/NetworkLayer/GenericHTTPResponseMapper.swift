//
//  GenericHTTPResponseMapper.swift
//  StreamingApp
//
//  Created by Nghia Dao on 15/2/25.
//
import Foundation

struct GenericHTTPResponseMapper {
    static func map<T>(data: Data, response: HTTPURLResponse) throws -> T where T: Decodable {
        let status = HTTPResponseStatus(rawValue: response.statusCode)
        switch status {
        case .success:
            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(T.self, from: data)
            return decodedResponse
        case .expiredToken:
            throw RequestError.tokenExpired
        default:
            throw RequestError.unexpectedStatusCode(description: "Status Code: \(response.statusCode)")
        }
    }
}
