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
    private var searchOperation: AnyCancellable?
    private var searchTerm: String?
    private var totalPages: Int = 0
    private var totalResults: Int = 0

    private var state: State = .idle(model: nil) {
        didSet {
            logger.debug("State: \(oldValue) -> \(self.state)")

            // If old state and the current state are `isSearching`, update search operation with new search
            // term and continue. If the old state and the new state are identical, do nothing and return.
            // Otherwise, proceed with he action to the state change.
            switch (oldValue, state) {
                // Consecutive idle events are possible if we are asked to start a search with an empty search-term.
                // In this case we clear our state so as to display nothing.
            case (.idle, .idle):
                resetInternalState()

                // Invalid transitions. The current operation must complete and it associated result must be returned.
            case (.isFetching, .isFetching), (.isSearching, .isSearching), (.isSearching, .isFetching), (.isFetching, .isSearching):
                return

                // Completion of a search results in updating our internal state (totalPages, totalResults, lastFetchedPage,
                // and movies), unless the result was an error. In that case, the internal state is unchanged. In the
                // case where no data is returned, the state is updated with zeros in order to indicate this. Arguably,
                // this might be better modeled as a separate state but I'm not doing that in this initial pass.
            case (.isSearching, .idle(model: let model)):
                if let model = model {
                    assert(model.page == 1)
                    // We successfully fetched the first page of data. Overwrite existing internal state. Note that if
                    // there was no data, then all state except `model.page` will be zero (observed).
                    lastFetchedPage = model.page
                    totalPages = model.totalPages
                    totalResults = model.totalResults
                    movies.send(model.results)
                } /* else { // Error state: Let's not wipe; see how the UI behaves.
                    resetInternalState()
                } */

                // Completion of a fetch results in updating our internal state, unless the result was an error. In the
                // case where no data is returned, we also intentionally do not update the internal state. This would
                // clear existing results from previous pages unnecessarily.
            case (.isFetching, .idle(model: let model)):
                if let model = model {
                    // FIXME: This operation can potentially exhaust device memory!
                    lastFetchedPage = model.page
                    totalPages = model.totalPages
                    totalResults = model.totalResults
                    var newMovies = movies.value
                    newMovies.append(contentsOf: model.results)
                    movies.send(newMovies)
                }

            case (.idle, .isSearching(searchTerm: let searchTerm)):
                self.searchTerm = searchTerm
                searchOperation = search(for: searchTerm)

            case (.idle, .isFetching(page: let page)):
                searchOperation = fetch(page: page)
            }

            currentState.send(state)
        }
    }

    var movies = CurrentValueSubject<[Movie], Never>([Movie]())

    init() {
        // FIXME: Remove if unused!
    }

    private func fetch(page: Int) -> AnyCancellable {
        // NOTE: FSM should protect against a search without a valid pre-existing search-term.
        return Network.shared.searchMovies(for: searchTerm!, page: page)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                if case let .failure(error) = completion {
                    self.logger.debug("Fetch for \(self.searchTerm!), page \(page) failed with error: \(error.localizedDescription)")
                    self.state = .idle(model: nil)
                }
            } receiveValue: { [weak self] movieSearchResults in
                self?.state = .idle(model: movieSearchResults)
            }
    }

    private func resetInternalState() {
        searchOperation?.cancel()
        lastFetchedPage = 0
        totalPages = 0
        totalResults = 0
        movies.send([])
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

    public func fetchNextPage() {
        guard lastFetchedPage != 0 else { return }
        state = .isFetching(page: lastFetchedPage + 1)
    }

    public func startSearch(for searchTerm: String) {
        guard !searchTerm.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            state = .idle(model: nil)
            return
        }
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
