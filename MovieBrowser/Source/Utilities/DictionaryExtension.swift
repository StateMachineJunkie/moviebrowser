//
//  DictionaryExtensions.swift
//
//  Created by Michael A. Crawford on 9/3/21.
//  Copyright © 2021 CDE, LLC. All rights reserved.
//

import Foundation

extension Dictionary where Key == String, Value: Any {
    /// Converts all dictionary key/value pairs into query items.
    /// - Note We only expect the four basic types (Bool, Int, Double, and String) to be used as parameters.
    ///        Any other type included in the parameter dictionary will be filtered out.
    public var queryItems: [URLQueryItem]? {
        guard count > 0 else { return nil }

        let queryItems: [URLQueryItem] = self.compactMap { (key, value) in
            let stringValue: String

            if let value = value as? String {
                stringValue = value
            } else if let value = value as? Double {
                stringValue = String(value)
            } else if let value = value as? Int {
                stringValue = String(value)
            } else if let value = value as? Bool {
                stringValue = value ? "true" : "false"
            } else {
                return nil
            }

            return URLQueryItem(name: key, value: stringValue)
        }
        return queryItems
    }
}
