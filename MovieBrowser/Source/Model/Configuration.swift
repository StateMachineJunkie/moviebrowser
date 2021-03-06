//
//  Configuration.swift
//  MovieBrowser
//
//  Created by Michael A. Crawford on 12/13/21.
//  Copyright © 2021 CDE, LLC. All rights reserved.
//

import Foundation

struct Configuration: Codable, Equatable {
    let images: ImageConfig
    let changeKeys: [String]
}

struct ImageConfig: Codable, Equatable {
    let baseUrl: String
    let secureBaseUrl: String
    let backdropSizes: [String]
    let logoSizes: [String]
    let posterSizes: [String]
    let profileSizes: [String]
    let stillSizes: [String]
}
