////
//  GitHubRepoTests.swift
//  GitHubRepo
//
//  Created by Jesse Chen on 2024/5/19.
//

@testable import GitHubRepo
import RxSwift
import XCTest

final class GitHubAPITest: XCTestCase {

    func testPath() {
        XCTAssertEqual(
            GitHubAPI.searchRepo(q: "Apple", sort: nil, order: nil, pageSize: nil, page: nil).path,
            "/search/repositories"
        )

        XCTAssertEqual(GitHubAPI.getRepo(owner: "Apple", repo: "cups").path, "/repos/Apple/cups")
    }

    func testParameters() {
        XCTAssertEqual(
            GitHubAPI.searchRepo(q: "Apple", sort: nil, order: nil, pageSize: nil, page: nil).parameters,
            ["q": "Apple"]
        )

        XCTAssertEqual(GitHubAPI.getRepo(owner: "Apple", repo: "cups").parameters, nil)
    }
}
