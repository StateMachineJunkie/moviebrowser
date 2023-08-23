//
//  SearchViewController.swift
//  SampleApp
//
//  Created by Michael A. Crawford on 12/13/21.
//  Copyright © 2021 CDE, LLC. All rights reserved.
//

import Combine
import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    private var activityIndicator = ActivityVC()
    private var movieList = MovieList()
    private var subscriptions = Set<AnyCancellable>()
    private var noData = false

    // MARK: - UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureNavigationBar()
        bindMovieList()
        bindSearchBar()
    }

    @IBAction func didTapGoButton(_ sender: Any) {
        self.movieList.startSearch(for: searchBar.searchTextField.text ?? "")
    }

    private func bindMovieList() {
        movieList.currentState
            .sink { [unowned self] state in
                switch state {
                case .isFetching, .isSearching, .isLoadingConfig:
                    self.activityIndicator.show(in: self)
                case let .idle(model):
                    self.activityIndicator.hide()

                    if let model = model, model.results.isEmpty {
                        noData = true
                        self.tableView.reloadData()
                    } else {
                        noData = false
                    }
                case .configLoadFailure(error: let error):
                    let message = """
                    I was unable to load the network configuration. This means that I will not be able to display movie
                    posters. Instead you will see a common place-holder image. Sorry for the inconvenience.
                    """
                    self.alertOk(error.localizedDescription, message: NSLocalizedString(message, comment: ""), completion: { [unowned self] in
                        self.movieList.resetConfigError()
                    })
                }
            }
            .store(in: &subscriptions)

        movieList.movies
            .sink { [unowned self] _ in
            self.tableView.reloadData()
        }
        .store(in: &subscriptions)

        movieList.start()
    }

    private func bindSearchBar() {
        let textDidChangePublisher = NotificationCenter
            .default
            .publisher(for: UISearchTextField.textDidChangeNotification, object: searchBar.searchTextField)

        textDidChangePublisher
            .map { (notification) -> Bool in
                let textField = notification.object as! UISearchTextField
                guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return false }
                return !text.isEmpty
            }
            .assign(to: \.isEnabled, on: goButton)
            .store(in: &subscriptions)

        goButton.isEnabled = false
        searchBar.delegate = self
    }

    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBlue
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
    }

    private func configureTableView() {
        title = NSLocalizedString("Movie Search", comment: "")
        tableView.keyboardDismissMode = .onDrag
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let movie = movieList.movies.value[indexPath.row]
        let storyboard = UIStoryboard(name: "MovieDetail", bundle: Bundle.main)
        let controller = storyboard.instantiateInitialViewController() as! MovieDetailViewController
        controller.configuration = movieList.configuration
        controller.movie = movie
        navigationController?.pushViewController(controller, animated: true)
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if noData {
            return "No Data"
        } else {
            return nil
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if goButton.isEnabled {
            didTapGoButton(searchBar)
        }
    }
}
