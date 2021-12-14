//
//  NetworkError.swift
//  MovieBrowser
//
//  Created by Michael A. Crawford on 12/13/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//

import Foundation

struct NetworkError: Codable, Equatable {
    let statusMessage: String
    let statusCode: Int
}

extension NetworkError: CustomStringConvertible {
    var description: String {
        return "\(statusCode): \(statusMessage)"
    }
}