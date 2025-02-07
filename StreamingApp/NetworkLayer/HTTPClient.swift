//
//  HTTPClient.swift
//  Streaming
//
//  Created by Nghia Dao on 6/2/25.
//
import Foundation
import Combine

protocol HTTPClient {
    func sendRequest(_ request: HTTPRequest) async throws -> (Data, HTTPURLResponse)
//    func sendRequest(_ endpoint: Endpoint) -> AnyPublisher<Data, RequestError>
}

// MARK: - APIRequestHandler

struct HTTPClientHandler: HTTPClient {
    let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func sendRequest(_ request: HTTPRequest) async throws -> (Data, HTTPURLResponse) {
        let urlRequest = try request.createURLRequest()
        let (data, response) = try await session.data(for: urlRequest)

        guard let response = response as? HTTPURLResponse else {
            throw RequestError.failed(description: "Request Failed.")
        }

        return (data, response)
//        switch response.statusCode {
//        case 200...299:
//            return data
//        case 505:
//            throw RequestError.tokenExpired
//        case 401:
//            throw RequestError.unauthorized
//        default:
//            throw RequestError.unexpectedStatusCode(description: "Status Code: \(response.statusCode)")
//        }
    }

//    public func sendRequest(_ endpoint: Request) -> AnyPublisher<Data, RequestError> {
//        guard let urlRequest = try? request.createURLRequest() else {
//            return Fail(error: RequestError.invalidURL)
//                .eraseToAnyPublisher()
//        }
//        return session
//            .dataTaskPublisher(for: urlRequest)
//            .subscribe(on: DispatchQueue.global())
//            .tryMap { (data, response) -> Data in
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    throw RequestError.failed(description: "Request Failed.")
//                }
//                switch httpResponse.statusCode {
//                case 200...299:
//                    return data
//                case 401:
//                    throw RequestError.unauthorized
//                default:
//                    throw RequestError.unexpectedStatusCode(description: "Status Code: \(httpResponse.statusCode)")
//                }
//            }
//            .mapError { error -> RequestError in
//                if let requestError = error as? RequestError {
//                    return requestError
//                }
//                return RequestError.unknown
//            }
//            .eraseToAnyPublisher()
//    }
}
