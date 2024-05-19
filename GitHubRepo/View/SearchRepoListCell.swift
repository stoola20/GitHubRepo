////
//  SearchRepoListCell.swift
//  GitHubRepo
//
//  Created by Jesse Chen on 2024/5/17.
//

import UIKit

class SearchRepoListCell: UITableViewCell {
    /// The image view displaying the user's avatar.
    @IBOutlet var avatarImageView: UIImageView!
    /// The label displaying the repo full name.
    @IBOutlet var repoNameLabel: UILabel!
    /// The label displaying the description.
    @IBOutlet var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
    }

    /// Configures the cell with repository data.
    ///
    /// - Parameter repo: The repository data to display.
    func configureCell(with repo: SearchRepoItem) {
        avatarImageView.loadImage(repo.owner.avatarUrl)
        repoNameLabel.text = repo.fullName
        descriptionLabel.text = repo.description
    }

    /// Sets up the initial UI configurations for the cell.
    private func setUpUI() {
        avatarImageView.contentMode = .scaleAspectFill

        repoNameLabel.font = .boldSystemFont(ofSize: 17)
        repoNameLabel.numberOfLines = 1

        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.numberOfLines = 3
    }
}
