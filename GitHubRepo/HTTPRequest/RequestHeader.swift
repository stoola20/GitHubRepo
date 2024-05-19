////
//  RequestHeader.swift
//  GitHubRepo
//
//  Created by Jesse Chen on 2024/5/17.
//
//

import Foundation

/// Protocol defining a custom HTTP header key and value.
protocol CustomHeader {
    /// The key of the HTTP header.
    var key: String { get }
    /// The value of the HTTP header.
    var value: String { get }
}

/// Protocol defining a provider for HTTP headers.
protocol HTTPHeaderProvider {
    var headers: [String: String] { get }
}

/// Struct representing the 'Accept' header for GitHub API requests.
struct AcceptHeader: CustomHeader, HTTPHeaderProvider {
    var key: String { "Accept" }
    var value: String { "application/vnd.github+json" }
    var headers: [String: String] { [key: value] }
}

/// Struct representing the 'X-GitHub-Api-Version' header for GitHub API requests.
struct APIVersionHeader: CustomHeader, HTTPHeaderProvider {
    var key: String { "X-GitHub-Api-Version" }
    var value: String { "2022-11-28" }
    var headers: [String: String] { [key: value] }
}

/// Struct representing the 'Authorization' header for GitHub API requests.
struct AuthorizationHeader: CustomHeader, HTTPHeaderProvider {
    var key: String { "Authorization" }
    var value: String { "Bearer \(PersonalAccessToken.token)" }
    var headers: [String: String] { [key: value] }
}

class HTTPHeaderManager {
    static let shared = HTTPHeaderManager()
    
    private init() {}
    
    /// Retrieves the default HTTP headers for the application.
    /// - Returns: A dictionary containing the default HTTP headers.
    func getDefaultHeaders() -> [String: String] {
        var headers: [String: String] = [:]
        headers.merge(AcceptHeader().headers) { (_, new) in new }
        headers.merge(APIVersionHeader().headers) { (_, new) in new }
        headers.merge(AuthorizationHeader().headers) { (_, new) in new }
        return headers
    }
}
