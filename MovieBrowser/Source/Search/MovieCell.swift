//
//  MovieCell.swift
//  MovieBrowser
//
//  Created by Michael A. Crawford on 12/13/21.
//  Copyright © 2021 CDE, LLC. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var popularityLabel: UILabel!

    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    static var reuseIdentifier: String { String(describing: MovieCell.self) }

    func configure(with movie: Movie) {
        titleLabel.text = movie.title

        if let popularity = movie.popularity {
            popularityLabel.text = String(round(popularity))
        } else {
            popularityLabel.text = NSLocalizedString("Unknown", comment: "")
        }

        if let releaseDate = movie.releaseDate {
            releaseDateLabel.text = Self.dateFormatter.string(from: releaseDate)
        } else {
            releaseDateLabel.text = NSLocalizedString("Unknown", comment: "")
        }
    }
}
