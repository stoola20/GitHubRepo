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

    func configureCell(with repo: SearchRepoItem) {
        avatarImageView.loadImage(repo.owner.avatarUrl)
        repoNameLabel.text = repo.fullName
        descriptionLabel.text = repo.description
    }

    private func setUpUI() {
        avatarImageView.contentMode = .scaleAspectFill

        repoNameLabel.font = .boldSystemFont(ofSize: 17)
        repoNameLabel.numberOfLines = 0

        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.numberOfLines = 0
    }
}
