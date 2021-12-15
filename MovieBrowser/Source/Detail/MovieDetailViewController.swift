//
//  MovieDetailViewController.swift
//  SampleApp
//
//  Created by Struzinski, Mark on 2/26/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//

import Combine
import os.log
import UIKit

class MovieDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var overviewLabel: UILabel!

    var configuration: Configuration!
    var movie: Movie!

    private let logger = Logger(subsystem: "\(Bundle.main.loggingId)", category: "MovieDetail")

    private static var releaseDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()

    private var publisher: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = movie.title
        overviewLabel.text = movie.overview

        let releaseDatePrefix = NSLocalizedString("Release Date:", comment: "")
        let releaseDateSuffix = NSLocalizedString("Unknown", comment: "")

        if let date = movie.releaseDate {
            releaseDateLabel.text = "\(releaseDatePrefix) \(Self.releaseDateFormatter.string(from: date))"
        } else {
            releaseDateLabel.text = "\(releaseDatePrefix) \(releaseDateSuffix)"
        }

        guard let config = configuration else {
            logger.warning("API configuration is unavailable. Therefore movie posters will not be displayed.")
            return
        }

        guard let path = createPath(for: movie, with: config) else { return }
        loadPoster(at: path)
    }

    private func createPath(for movie: Movie, with config: Configuration) -> String? {
        guard let posterPath = movie.posterPath else { return nil }
        var path = NSString(string: config.images.secureBaseUrl).appendingPathComponent(config.images.posterSizes[2])
        path = NSString(string: path).appendingPathComponent(posterPath)
        return path
    }

    private func loadPoster(at path: String) {
        guard let url = URL(string: path) else { return }
        publisher = ImageLoader.shared.loadImage(from: url)
            .sink { [weak self] image in
                if let posterImageView = self?.posterImageView, let image = image {
                    UIView.transition(with: posterImageView, duration: 0.25, options: /*.transitionCrossDissolve*/ .transitionFlipFromLeft, animations: {
                        posterImageView.image = image
                    })
                }
            }
    }
}
