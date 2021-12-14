//
//  BundleExtension.swift
//  MovieBrowser
//
//  Created by Michael A. Crawford on 12/13/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//

import Foundation

extension Bundle {
    var loggingId: String {
        if let id = Bundle.main.bundleIdentifier {
            return id
        } else {
            return Bundle.main.description
        }
    }
}
