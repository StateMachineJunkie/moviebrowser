//
//  MovieSearchResults.swift
//  MovieBrowser
//
//  Created by Michael A. Crawford on 12/13/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//

import Foundation

struct MovieSearchResults: Codable, Equatable {
    let page: Int
    let results: [Movie]
    let totalResults: Int
    let totalPages: Int
}
