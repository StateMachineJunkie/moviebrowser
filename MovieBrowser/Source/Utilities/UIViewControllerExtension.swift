//
//  UIViewControllerExtension.swift
//
//  Created by Michael A. Crawford on 8/14/19.
//  Copyright © 2021 CDE, LLC. All rights reserved.
//

import UIKit

// MARK: - Convenient UIAlertController instantiation

extension UIViewController {
    /// Shows an alert with one button.
    ///
    /// - Parameters:
    ///   - title: Alert title.
    ///   - message: Helpful message.
    ///   - button: title for `button`
    ///   - handler: Closure to be invoked when the user taps `button`.
    ///   - completion: Closure to be invoked upon dismissal of the alert.
    func alert(_ title: String,
               message: String,
               button: String,
               handler: ((UIAlertAction) -> Void)?,
               completion: (() -> Void)?) {
        let aMessage: String? = message.isEmpty ? nil : message
        let alert = UIAlertController(title: title, message: aMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: button, style: .default, handler: handler)
        alert.addAction(action)
        present(alert, animated: true, completion: completion)
    }

    // swiftlint:disable function_parameter_count
    /// Show an alert with two buttons. `button1` is the default action.
    /// `button2` is the cancel action.
    ///
    /// - Parameters:
    ///   - title: Alert title.
    ///   - message: Helpful message.
    ///   - button1: Title for `button1`.
    ///   - handler1: Closure to be invoked when the user taps `button1`.
    ///   - button2: Title for `button2`.
    ///   - handler2: Closure to be invoked when the user taps `button2`.
    ///   - completion: Closure to be invoked upon dismissal of the alert.
    func alert(_ title: String,
               message: String,
               button1: String,
               handler1: ((UIAlertAction) -> Void)?,
               button2: String,
               handler2: ((UIAlertAction) -> Void)?,
               completion: (() -> Void)?) {
        let aMessage: String? = message.isEmpty ? nil : message
        let alert = UIAlertController(title: title, message: aMessage, preferredStyle: .alert)
        let action1 = UIAlertAction(title: button1, style: .default, handler: handler1)
        let action2 = UIAlertAction(title: button2, style: .cancel, handler: handler2)
        alert.addAction(action1)
        alert.addAction(action2)
        present(alert, animated: true, completion: completion)
    }

    /// Shows an alert with an OK button.
    func alertOk(_ title: String, message: String = "", ok: ((UIAlertAction) -> Void)? = nil,
                 completion: (() -> Void)? = nil) {
        alert(title, message: message,
              button: NSLocalizedString("Ok", comment: ""),
              handler: ok,
              completion: completion)
    }

    /// Shows and alert with Ok and Cancel buttons.
    func alertOkCancel(_ title: String,
                       message: String = "",
                       ok: ((UIAlertAction) -> Void)? = nil,
                       cancel: ((UIAlertAction) -> Void)? = nil,
                       completion: (() -> Void)? = nil) {
        alert(title,
              message: message,
              button1: NSLocalizedString("Ok", comment: ""),
              handler1: ok,
              button2: NSLocalizedString("Cancel", comment: ""),
              handler2: cancel,
              completion: completion)
    }
}
