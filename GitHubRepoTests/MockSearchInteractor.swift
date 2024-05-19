////
//  MockSearchInteractor.swift
//  GitHubRepo
//
//  Created by Jesse Chen on 2024/5/19.
//

@testable import GitHubRepo
import RxSwift
import XCTest

final class MockSearchInteractor: SearchInteractorProtocol {
    var stubSearchRepoResult: Observable<SearchRepoList>!
    var stubGetRepoResult: Observable<DetailRepo>!

    func searchRepo(query: String, sort: SearchRepoParameterSort?, order: SearchRepoParameterOrder?, pageSize: Int?, page: Int?) -> Observable<SearchRepoList> {
        stubSearchRepoResult
    }

    func getRepo(owner: String, repo: String) -> Observable<DetailRepo> {
        stubGetRepoResult
    }
}
