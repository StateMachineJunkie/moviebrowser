//
//  Network.swift
//  SampleApp
//
//  Created by Struzinski, Mark - Mark on 9/17/20.
//  Copyright © 2020 Lowe's Home Improvement. All rights reserved.
//

import Combine
import os.log
import Foundation

class Network {
    enum Error: Swift.Error {
        case clientError(NetworkError)
        case serverError(NetworkError)
        case noData
    }

    private enum API {
        case getConfig
        case getMovieGenreList
        case movieSearch

        var apiKey: String { "5885c445eab51c7004916b9c0313e2d3" }
        var baseURL: String { "https://api.themoviedb.org/3" }

        var path: String {
            switch self {
            case .getConfig:
                return "/configuration"
            case .getMovieGenreList:
                return "/genre/movie/list"
            case .movieSearch:
                return "/search/movie"
            }
        }

        var url: URL { URL(string: "\(baseURL)\(path)?api_key=\(apiKey)")! }
    }


    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()

    private static let dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.custom({ decoder -> Date in
        let container = try decoder.singleValueContainer()
        var dateString = try container.decode(String.self)
        guard let date = Network.shared.dateFormatter.date(from: dateString) else {
            logger.fault("While decoding date information the given date value is not in the expected format.")
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "The date value is not in the expected format!")
        }
        return date
    })

    private static let logger = Logger(subsystem: "\(Bundle.main.loggingId)", category: "Network")

    var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    static private(set) var shared = Network()

    private init() {}

    func getAPIConfig() -> Future<Configuration, Swift.Error> {
        Future { promise in
            let request = URLRequest(url: Network.API.getConfig.url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }

                guard let data = data else {
                    promise(.failure(Error.noData))
                    return
                }

                do {
                    let model = try Network.shared.jsonDecoder.decode(Configuration.self, from: data)
                    promise(.success(model))
                } catch {
                    promise(.failure(error))
                }
            }
            task.resume()
        }
    }

    func getMovieGenres() -> Future<Genres, Swift.Error> {
        Future { promise in
            let request = URLRequest(url: Network.API.getMovieGenreList.url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }

                guard let data = data else {
                    promise(.failure(Error.noData))
                    return
                }

                do {
                    let model = try Network.shared.jsonDecoder.decode(Genres.self, from: data)
                    promise(.success(model))
                } catch {
                    promise(.failure(error))
                }
            }
            task.resume()
        }
    }

    func searchMovies(for searchValue: String, page: Int = 1) -> Future<MovieSearchResults, Swift.Error> {
        Future { promise in
            var urlComponents = URLComponents(url: Network.API.movieSearch.url, resolvingAgainstBaseURL: false)!
            urlComponents.queryItems = [
                "api_key": Network.API.movieSearch.apiKey,
                "query": searchValue,
                "page": page
            ].queryItems

            let request = URLRequest(url: urlComponents.url!, cachePolicy: .reloadIgnoringLocalCacheData)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }

                guard let data = data else {
                    promise(.failure(Error.noData))
                    return
                }

                do {
                    let model = try Network.shared.jsonDecoder.decode(MovieSearchResults.self, from: data)
                    promise(.success(model))
                } catch {
                    promise(.failure(error))
                }
            }
            task.resume()
        }
    }
}
