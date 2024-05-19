////
//  UIImageView+Ext.swift
//  GitHubRepo
//
//  Created by Jesse Chen on 2024/5/17.
//

import Kingfisher
import UIKit

extension UIImageView {
    /// Loads an image from the specified URL asynchronously using Kingfisher and sets it as the image of the image view.
    ///
    /// - Parameters:
    ///   - urlString: The URL string from which to load the image.
    ///   - placeHolder: An optional placeholder image to display while the image is being loaded. Defaults to nil.
    func loadImage(_ urlString: String?, placeHolder: UIImage? = nil) {
        // Ensure that the urlString is not nil and can be converted to a URL.
        guard let urlString, let url = URL(string: urlString) else { return }

        // Set the Kingfisher indicator type to activity indicator.
        self.kf.indicatorType = .activity

        // Use Kingfisher to asynchronously load the image from the URL and set it as the image of the image view.
        self.kf.setImage(
            with: url,
            placeholder: placeHolder,
            options: [
                .transition(.fade(1)), // Apply a fade transition when the image is loaded.
                .cacheOriginalImage // Cache the original image for future use.
            ]
        )
    }
}
