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

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Movie Search", comment: "")
        
        movieList.currentState
            .removeDuplicates()
            .sink { state in
            switch state {
            case .isFetching, .isSearching:
                self.activityIndicator.show(in: self)
            case .idle:
                self.activityIndicator.hide()
            }
        }
        .store(in: &subscriptions)

        movieList.movies
            .sink { _ in
            self.tableView.reloadData()
        }
        .store(in: &subscriptions)

        // TODO: Combine search bar

        movieList.startSearch(for: "Star Wars")
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
        let count = movieList.movies.value.count    // TODO: simplify
        return count
    }
}

extension SearchViewController: UITableViewDelegate {

}
