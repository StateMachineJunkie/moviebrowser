//
//  DateExtension.swift
//  MovieBrowser
//
//  Created by Michael A. Crawford on 12/13/21.
//  Copyright © 2021 CDE, LLC. All rights reserved.
//

import Foundation

extension Date {
    /// Returns the date as a string formatted as yyyy-mm-dd.
    func stringValue() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}
