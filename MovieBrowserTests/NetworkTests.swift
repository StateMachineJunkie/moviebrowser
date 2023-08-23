//
//  NetworkTests.swift
//  MovieBrowserTests
//
//  Created by Michael A. Crawford on 12/13/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//

import Combine
import XCTest
@testable import MovieBrowser

class NetworkTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Decoder Verification
    // Tests used for configuring my decoder. In this case, the key-decoding strategy and some date handling is all that
    // is needed. But I've worked with plenty of APIs that had numerous problems with consistency in both the coding and
    // the documentation.

    func testConfigDecode() throws {
        let decoder = Network.shared.jsonDecoder
        let model = try decoder.decode(Configuration.self, from: getTestConfigData())
        print(model)
    }

    func testGenreDecode() throws {
        let decoder = Network.shared.jsonDecoder
        let model = try decoder.decode(Genres.self, from: getTestGenreData())
        print(model)
    }

    func testMovieDecode() throws {
        let decoder = Network.shared.jsonDecoder
        let model = try decoder.decode(MovieSearchResults.self, from: getTestMovieData())
        print(model)
    }

    // MARK: - Basic API Method Verification (no mock)

    func testGetConfig() throws {
        var subscriptions = Set<AnyCancellable>()
        let expectation = expectation(description: "Get MovieDB configuration")
        Network.shared.getAPIConfig().sink { completion in
            if case let .failure(error) = completion {
                XCTFail("Failed to fetch MovieDB configuration. Error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        } receiveValue: { model in
            print(model)
            expectation.fulfill()
        }
        .store(in: &subscriptions)
        wait(for: [expectation], timeout: 20.0)
    }

    func testGetMovieGenreList() throws {
        var subscriptions = Set<AnyCancellable>()
        let expectation = expectation(description: "Get MovieDB genres")
        Network.shared.getMovieGenres().sink { completion in
            if case let .failure(error) = completion {
                XCTFail("Failed to fetch MovieDB genres. Error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        } receiveValue: { model in
            print(model)
            expectation.fulfill()
        }
        .store(in: &subscriptions)
        wait(for: [expectation], timeout: 20.0)
    }

    func testSearchMovies() throws {
        var subscriptions = Set<AnyCancellable>()
        let expectation = expectation(description: "Search Movies")
        Network.shared.searchMovies(for: "Star Wars").sink { completion in
            if case let .failure(error) = completion {
                XCTFail("Query for movies named Star Wars failed with error: \(error.localizedDescription)")
                expectation.fulfill()
            }
        } receiveValue: { model in
            print("Received \(model.totalResults) result(s)")
            expectation.fulfill()
        }
        .store(in: &subscriptions)
        wait(for: [expectation], timeout: 20.0)
    }

    private func getTestConfigData() -> Data {
        return """
        {"images":{"base_url":"http://image.tmdb.org/t/p/","secure_base_url":"https://image.tmdb.org/t/p/","backdrop_sizes":["w300","w780","w1280","original"],"logo_sizes":["w45","w92","w154","w185","w300","w500","original"],"poster_sizes":["w92","w154","w185","w342","w500","w780","original"],"profile_sizes":["w45","w185","h632","original"],"still_sizes":["w92","w185","w300","original"]},"change_keys":["adult","air_date","also_known_as","alternative_titles","biography","birthday","budget","cast","certifications","character_names","created_by","crew","deathday","episode","episode_number","episode_run_time","freebase_id","freebase_mid","general","genres","guest_stars","homepage","images","imdb_id","languages","name","network","origin_country","original_name","original_title","overview","parts","place_of_birth","plot_keywords","production_code","production_companies","production_countries","releases","revenue","runtime","season","season_number","season_regular","spoken_languages","status","tagline","title","translations","tvdb_id","tvrage_id","type","video","videos"]}
        """.data(using: .utf8)!
    }

    private func getTestGenreData() -> Data {
        return """
        {"genres":[{"id":28,"name":"Action"},{"id":12,"name":"Adventure"},{"id":16,"name":"Animation"},{"id":35,"name":"Comedy"},{"id":80,"name":"Crime"},{"id":99,"name":"Documentary"},{"id":18,"name":"Drama"},{"id":10751,"name":"Family"},{"id":14,"name":"Fantasy"},{"id":36,"name":"History"},{"id":27,"name":"Horror"},{"id":10402,"name":"Music"},{"id":9648,"name":"Mystery"},{"id":10749,"name":"Romance"},{"id":878,"name":"Science Fiction"},{"id":10770,"name":"TV Movie"},{"id":53,"name":"Thriller"},{"id":10752,"name":"War"},{"id":37,"name":"Western"}]}
        """.data(using: .utf8)!
    }

    private func getTestMovieData() -> Data {
        return """
        {"page":1,"results":[{"adult":false,"backdrop_path":"/iPnH51khswDrYij6XIBHKlAznW.jpg","genre_ids":[12,28,878],"id":11,"original_language":"en","original_title":"Star Wars","overview":"Princess Leia is captured and held hostage by the evil Imperial forces in their effort to take over the galactic Empire. Venturesome Luke Skywalker and dashing captain Han Solo team together with the loveable robot duo R2-D2 and C-3PO to rescue the beautiful princess and restore peace and justice in the Empire.","popularity":65.03,"poster_path":"/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg","release_date":"1977-05-25","title":"Star Wars","video":false,"vote_average":8.2,"vote_count":16371}],"total_pages":1,"total_results":1}
        """.data(using: .utf8)!
    }
}
