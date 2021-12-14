//
//  SearchViewController.swift
//  SampleApp
//
//  Created by Struzinski, Mark on 2/19/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//

import Combine
import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    private var activityIndicator = ActivityVC()
    private var movieList = MovieList()
    private var subscriptions = Set<AnyCancellable>()
    private var noData = false

    // MARK: - UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Movie Search", comment: "")
        
        movieList.currentState
            .sink { [unowned self] state in
                switch state {
                case .isFetching, .isSearching:
                    self.activityIndicator.show(in: self)
                case let .idle(model):
                    self.activityIndicator.hide()

                    if let model = model, model.results.isEmpty {
                        noData = true
                        self.tableView.reloadData()
                    } else {
                        noData = false
                    }
                }
            }
            .store(in: &subscriptions)

        movieList.movies
            .sink { [unowned self] _ in
            self.tableView.reloadData()
        }
        .store(in: &subscriptions)

        bindSearchBar()
    }

    private func bindSearchBar() {
        let publisher = NotificationCenter
            .default
            .publisher(for: UISearchTextField.textDidChangeNotification, object: searchBar.searchTextField)
        publisher
            .map { ($0.object as! UISearchTextField).text }
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [unowned self] searchText in
                self.movieList.startSearch(for: searchText ?? "")
            }
            .store(in: &subscriptions)
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.reuseIdentifier, for: indexPath) as! MovieCell
        let movie = movieList.movies.value[indexPath.row]
        cell.configure(with: movie)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movieList.movies.value.count
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if noData {
            return "No Data"
        } else {
            return nil
        }
    }
}
