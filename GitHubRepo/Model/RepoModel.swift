////
//  RepoModel.swift
//  GitHubRepo
//
//  Created by Jesse Chen on 2024/5/17.
//

import Foundation
import RxDataSources

/// Structure representing a section in a repo list, containing a header and a list of items.
/// This custom structure can be pass to RxDataSources as section type.
struct SearchRepoSection: SectionModelType {
    /// The header title of the section.
    var header: String
    /// The items contained within the section.
    var items: [Item]
}

extension SearchRepoSection {
    typealias Item = SearchRepoItem

    init(original: SearchRepoSection, items: [SearchRepoItem]) {
        self = original
        self.items = items
    }
}

/// This structure represents a list of repositories returned from a search query.
struct SearchRepoList: Decodable {
    let items: [SearchRepoItem]
}

/// This structure represents an individual repository item within the search results.
struct SearchRepoItem: Decodable {
    /// Name of the repo
    let name: String
    /// Name of the repo with prefixed owner login name
    ///
    /// - example:  TheAlgorithms/Java
    let fullName: String
    /// More description about the repo
    let description: String?
    /// The owner of the repo
    let owner: RepoOwner
}

/// This structure represents the owner of a repository.
struct RepoOwner: Decodable, Equatable {
    /// The username of the GitHub user.
    let login: String
    /// The URL of the avatar image for the GitHub user.
    let avatarUrl: String
}

/// This structure represents detailed information about a single repository.
struct DetailRepo: Decodable, Equatable {
    /// The owner of the repo
    let owner: RepoOwner
    /// Name of the repo
    let name: String
    /// Name of the repo with prefixed owner login name
    let fullName: String
    /// The language by which the repo us written
    let language: String?
    let stargazersCount: Int
    let watchersCount: Int
    let forksCount: Int
    let openIssuesCount: Int
}
