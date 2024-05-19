////
//  GitHubAPI.swift
//  GitHubRepo
//
//  Created by Jesse Chen on 2024/5/17.
//
//

import Alamofire
import Foundation

/// Enum representing different endpoints of the GitHub API.
enum GitHubAPI {

    case searchRepo(
        q: String,
        sort: SearchRepoParameterSort?,
        order: SearchRepoParameterOrder?,
        pageSize: Int?,
        page: Int?
    )

    case getRepo(
        owner: String,
        repo: String
    )
}

extension GitHubAPI {
    /// The base URL of the GitHub API.
    var baseURL: String {
        "https://api.github.com"
    }

    /// The path component of the URL for the API endpoint.
    var path: String {
        switch self {
        case .searchRepo:
            return "/search/repositories"
        case let .getRepo(owner, repo):
            return "/repos/\(owner)/\(repo)"
        }
    }

    /// The HTTP method used for the API request.
    var method: Alamofire.HTTPMethod {
        .get
    }

    /// The HTTP header fields for the API request.
    var header: [String: String] {
        HTTPHeaderManager.shared.getDefaultHeaders()
    }

    /// The parameters to be included in the API request.
    var parameters: [String: String]? {
        switch self {
        case let .searchRepo(q, sort, order, pageSize, page):
            var parameters = ["q": q]
            if let sort {
                parameters["sort"] = sort.rawValue
            }
            if let order {
                parameters["order"] = order.rawValue
            }
            if let pageSize {
                parameters["per_page"] = String(pageSize)
            }
            if let page {
                parameters["page"] = String(page)
            }
            return parameters
        case .getRepo:
            return nil
        }
    }
}

/// Enum representing sorting options for search repositories.
enum SearchRepoParameterSort: String {
    case stars
    case forks
    case helpWantedIssues = "help-wanted-issues"
    case updated
}

/// Enum representing ordering options for search repositories.
enum SearchRepoParameterOrder: String {
    case desc
    case asc
}
