//
//  AppConfig.swift
//  Streaming
//
//  Created by Nghia Dao on 6/2/25.
//

import Foundation

struct AppConfig {
    static var host: String {
         return Bundle.main.object(forInfoDictionaryKey: "Host") as? String ?? ""
    }
}
