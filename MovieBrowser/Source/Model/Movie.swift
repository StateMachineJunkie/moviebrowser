//
//  Movie.swift
//  MovieBrowser
//
//  Created by Michael A. Crawford on 12/13/21.
//  Copyright © 2021 CDE, LLC. All rights reserved.
//

import Foundation

struct Movie: Equatable, Identifiable {
    let posterPath: String?
    let adult: Bool
    let overview: String
    let releaseDate: Date?
    let id: Int
    let originalTitle: String
    let originalLanguage: String
    let title: String
    let backdropPath: String?
    let genreIds: [Int]?
    let popularity: Double?
    let voteCount: Int?
    let video: Bool?
    let voteAverage: Double?
}

extension Movie: Codable {
    init(from decoder: Decoder) throws {
        let container       = try decoder.container(keyedBy: CodingKeys.self)
        posterPath          = try container.decodeIfPresent(String.self, forKey: .posterPath)
        adult               = try container.decode(Bool.self, forKey: .adult)
        overview            = try container.decode(String.self, forKey: .overview)
        id                  = try container.decode(Int.self, forKey: .id)
        originalTitle       = try container.decode(String.self, forKey: .originalTitle)
        originalLanguage    = try container.decode(String.self, forKey: .originalLanguage)
        title               = try container.decode(String.self, forKey: .title)
        backdropPath        = try container.decodeIfPresent(String.self, forKey: .backdropPath)
        genreIds            = try container.decodeIfPresent([Int].self, forKey: .genreIds)
        popularity          = try container.decodeIfPresent(Double.self, forKey: .popularity)
        voteCount           = try container.decodeIfPresent(Int.self, forKey: .voteCount)
        video               = try container.decodeIfPresent(Bool.self, forKey: .video)
        voteAverage         = try container.decodeIfPresent(Double.self, forKey: .voteAverage)
        // We have to special-case this because TMDB sometimes sends a zero-length string for the date instead of `null`.
        do {
            releaseDate = try container.decodeIfPresent(Date.self, forKey: .releaseDate)
        } catch {
            releaseDate = nil
        }
    }
}
