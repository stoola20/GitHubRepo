////
//  TableView+Ext.swift
//  GitHubRepo
//
//  Created by Jesse Chen on 2024/5/17.
//

import UIKit

extension UITableView {
    /// Registers a cell class for use in creating new table view cells.
    ///
    /// - Parameters:
    ///   - cell: The cell class to register.
    ///   - bundle: The bundle containing the nib file. If nil, the main bundle is used.
    func register(cell: AnyClass, inBundle bundle: Bundle? = nil) {
        // Register the cell class using a nib file with the same name as the cell class.
        register(
            UINib(nibName: String(describing: cell.self), bundle: bundle),
            forCellReuseIdentifier: String(describing: cell.self)
        )
    }
}
