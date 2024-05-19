////
//  UIViewController+Ext.swift
//  GitHubRepo
//
//  Created by Jesse Chen on 2024/5/17.
//

import UIKit

extension UIViewController {
    /// Displays an alert with the specified title and message.
    ///
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - message: The message to display in the alert.
    ///   - confirm: A closure to execute when the user confirms the alert. Defaults to nil.
    ///   - cancel: A closure to execute when the user cancels the alert. Defaults to nil.
    func showAlert(
        title: String,
        message: String,
        confirm: (() -> Void)? = nil,
        cancel: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)

        // Add cancel action if provided
        if let cancel {
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                cancel()
            }
            alert.addAction(cancelAction)
        }

        // add confirm action
        let confirmAction = UIAlertAction(title: "OK", style: .default) { _ in
            confirm?()
        }
        alert.addAction(confirmAction)

        present(alert, animated: true, completion: nil)
    }
}

