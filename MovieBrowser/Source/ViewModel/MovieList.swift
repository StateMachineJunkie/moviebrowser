//
//  MovieListViewModel.swift
//  MovieBrowser
//
//  Created by Michael A. Crawford on 12/13/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//

import Combine
import Foundation
import os.log

class MovieList: ObservableObject {
    enum State: Equatable {
        case idle(model: MovieSearchResults?)
        case isSearching(searchTerm: String)
        case isFetching(page: Int)
    }

    private(set) var currentState = CurrentValueSubject<State, Never>(.idle(model: nil))
    private(set) var lastFetchedPage: Int = 0 // Zero means we haven't issue a fetch yet.
    private var logger = Logger(subsystem: "\(Bundle.main.loggingId)", category: "App")
    private(set) var searchTerm: String = ""
    private var searchOperation: AnyCancellable?
    private(set) var searchText = CurrentValueSubject<String, Never>("")
    private var totalPages: Int = 0
    private var totalResults: Int = 0

    private var state: State = .idle(model: nil) {
        didSet {
            logger.debug("State: \(oldValue) -> \(self.state)")

            // If old state and the current state are `isSearching`, update search operation with new search
            // term and continue. If the old state and the new state are identical, do nothing and return.
            // Otherwise, proceed with he action to the state change.
            switch (oldValue, state) {
            case (.idle, .idle), (.isFetching, .isFetching):
                return

            case let (.isSearching(oldSearchTerm), .isSearching(searchTerm)):
                if oldSearchTerm == searchTerm { return }
                searchOperation?.cancel()
                searchOperation = search(for: searchTerm)

            case (_, .idle(model: let model)):
                guard let model = model else { return }

                if model.page == 1 {
                    // We successfully fetched the first page of data. Overwrite existing internal state.
                    totalPages = model.totalPages
                    totalResults = model.totalResults
                    movies.send(model.results)
                } else {
                    // We successfully fetched an additional page of data. Append to existing internal state.
                    //movies.append(contentsOf: model.results) // FIXME: Memory management!
                }

            case (_, .isSearching(searchTerm: let searchTerm)):
                searchOperation = search(for: searchTerm)

            case (_, .isFetching(page: let page)):
                fetch(page: page)
            }
            currentState.send(state)
        }
    }

    var movies = CurrentValueSubject<[Movie], Never>([Movie]())

    init() {
        // FIXME: Remove if unused!
    }

    private func fetch(page: Int) {
        // TODO: We need to handle paging.
    }

    private func search(for searchTerm: String) -> AnyCancellable {
        Network.shared.searchMovies(for: searchTerm)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.logger.debug("Search for \(searchTerm) failed with error: \(error.localizedDescription)")
                self?.state = .idle(model: nil)
            }
        } receiveValue: { [weak self] movieSearchResults in
            self?.state = .idle(model: movieSearchResults)
        }
    }

    public func startSearch(for searchTerm: String) {
        state = .isSearching(searchTerm: searchTerm)
    }
}

extension MovieList.State: CustomStringConvertible {
    /// For debugging purposes, I want to monitor state transitions in the console. Conforming to `CustomStringConvertible`
    /// make this possible in combination with the new `Logger` API for iOS 15.
    var description: String {
        switch self {
        case let .idle(model: model):
            if let model = model {
                return "Is idle with \(model.totalResults) results in \(model.totalPages) page(s)."
            } else {
                return "Is idle with zero movies."
            }

        case let .isSearching(searchTerm: searchTerm):
            return "Is searching for \(searchTerm)."

        case let .isFetching(page: page):
            return "Is fetching page \(page)."
        }
    }
}
