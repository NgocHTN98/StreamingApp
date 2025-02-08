//
//  DemoNetworkService.swift
//  Streaming
//
//  Created by Nghia Dao on 6/2/25.
//

import Foundation

struct MockModel: Codable {
    let id: Int
    let name: String
}

struct DemoRequestProvider: HTTPRequest {
    var scheme: String = "https"
    var path: String = "/streamingmockitem/example"
    var method: HTTPMethod = .GET
    var headers: [String: String] = [:]
    var params: [String: Any] = [:]
}

protocol DemoNetworkService {
    func loadMockData() async throws -> MockModel
}

class DefaultDemoNetworkService: DemoNetworkService {
    let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func loadMockData() async throws -> MockModel {
        let request = DemoRequestProvider()
        do {
            print(try request.createURLRequest())
            let (data, response): (Data, HTTPURLResponse) = try await client.sendRequest(request)
            return try DemoListMapper.map(data: data, response: response)
        } catch {
            throw error
        }

    }
}

struct DemoListMapper {
    static func map(data: Data, response: HTTPURLResponse) throws -> MockModel {
        switch response.statusCode {
        case 200...299:
            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(MockModel.self, from: data)
            return decodedResponse
        case 505:
            throw RequestError.tokenExpired
        case 401:
            throw RequestError.unauthorized
        default:
            throw RequestError.unexpectedStatusCode(description: "Status Code: \(response.statusCode)")
        }
    }
}
