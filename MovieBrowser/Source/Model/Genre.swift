//
//  Genre.swift
//  MovieBrowser
//
//  Created by Michael A. Crawford on 12/13/21.
//  Copyright © 2021 CDE, LLC. All rights reserved.
//

import Foundation

struct Genre: Codable, Equatable, Identifiable {
    let id: Int
    let name: String
}

struct Genres: Codable, Equatable {
    let genres: [Genre]
}
