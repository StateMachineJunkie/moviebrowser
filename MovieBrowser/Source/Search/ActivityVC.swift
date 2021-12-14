//
//  ActivityVC.swift
//  MovieBrowser
//
//  Created by Michael A. Crawford on 12/13/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//

import UIKit

class ActivityVC: UIViewController {
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.25)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func hide() {
        if parent ==  nil { return }
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
        activityIndicator.stopAnimating()
    }

    func show(in parent: UIViewController) {
        guard self.parent == nil else { return }
        activityIndicator.startAnimating()
        parent.addChild(self)
        view.frame = parent.view.frame
        parent.view.addSubview(view)
        self.didMove(toParent: parent)
    }
}
