//
//  TokenRequest.swift
//  StreamingApp
//
//  Created by Nghia Dao on 8/2/25.
//

struct TokenRequest: HTTPRequest {
    var scheme: String = "https"
    var path: String = "/refreshToken"
    var method: HTTPMethod = .GET
    var headers: [String: String] = [:]
    var params: [String: Any] = [:]
}
