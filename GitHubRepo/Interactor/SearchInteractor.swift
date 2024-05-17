////
//  SearchInteractor.swift
//  GitHubRepo
//
//  Created by Jesse Chen on 2024/5/17.
//

import Foundation
import RxSwift

/// Protocol defining the methods required for searching repositories.
protocol SearchInteractorProtocol {
    /// Searches repositories based on the provided query and search parameters.
    ///
    /// - Parameters:
    ///   - query: The search query string.
    ///   - sort: The sorting parameter for the search results, if any.
    ///   - order: The ordering parameter for the search results, if any.
    ///   - pageSize: The number of results per page, if pagination is needed.
    ///   - page: The page number for paginated results, if pagination is needed.
    /// - Returns: An observable sequence of `SearchRepoList`.
    func searchRepo(
        query: String,
        sort: SearchRepoParameterSort?,
        order: SearchRepoParameterOrder?,
        pageSize: Int?,
        page: Int?
    ) -> Observable<SearchRepoList>
}

/// Concrete implementation of the `SearchInteractorProtocol` and `RequestProtocol`.
class SearchInteractor: SearchInteractorProtocol, RequestProtocol {
    func searchRepo(
        query: String,
        sort: SearchRepoParameterSort?,
        order: SearchRepoParameterOrder?,
        pageSize: Int?,
        page: Int?
    ) -> Observable<SearchRepoList> {

        let api = GitHubAPI.searchRepo(
            q: query,
            sort: sort,
            order: order,
            pageSize: pageSize,
            page: page
        )

        let url = URL(string: api.baseURL + api.path)

        return request(
            url: url,
            method: api.method,
            parameters: api.parameters,
            header: api.header,
            type: SearchRepoList.self
        )
    }
}
