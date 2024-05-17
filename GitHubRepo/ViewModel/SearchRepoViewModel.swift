////
//  SearchRepoViewModel.swift
//  GitHubRepo
//
//  Created by Jesse Chen on 2024/5/17.
//

import Foundation
import RxRelay
import RxSwift

/// Protocol defining the inputs required for the search repository view model.
protocol SearchRepoViewModelInputs {
    /// Relay for triggering the search operation.
    var searchTriggerRelay: PublishRelay<Void> { get }
    /// Relay for holding the search query string.
    var searchQueryRelay: BehaviorRelay<String> { get }
}

/// Protocol defining the outputs provided by the search repository view model.
protocol SearchRepoViewModelOutputs {
    /// Relay for holding the list of search repository items.
    var repoListRelay: BehaviorRelay<[SearchRepoItem]> { get }
    /// Relay for propagating errors occurred during the search operation.
    var errorRelay: PublishRelay<String> { get }
}

/// Protocol defining the combined type for the search repository view model.
protocol SearchRepoViewModelType {
    var inputs: SearchRepoViewModelInputs { get }
    var outputs: SearchRepoViewModelOutputs { get }
}

/// View model responsible for searching repositories.
class SearchRepoViewModel: SearchRepoViewModelInputs, SearchRepoViewModelOutputs, SearchRepoViewModelType {
    // MARK: Type

    var inputs: SearchRepoViewModelInputs { self }
    var outputs: SearchRepoViewModelOutputs { self }

    private let interactor: SearchInteractorProtocol
    private let disposeBag = DisposeBag()

    // MARK: Inputs

    let searchQueryRelay: BehaviorRelay<String> = .init(value: "")
    let searchTriggerRelay: PublishRelay<Void> = .init()

    // MARK: Outputs

    var repoListRelay: BehaviorRelay<[SearchRepoItem]> = .init(value: [])
    var errorRelay: PublishRelay<String> = .init()

    init(interactor: SearchInteractorProtocol = SearchInteractor()) {
        self.interactor = interactor

        let searchTrigger = searchTriggerRelay
            .asObservable()
            .withUnretained(self)
            .flatMapLatest { owner, _ -> Observable<SearchRepoList> in
                let query = owner.searchQueryRelay.value

                // Stop the operation and send error if query string is empty
                guard !query.isEmpty else {
                    owner.errorRelay.accept(ServerError.emptyQuery.errorDescription)
                    return Observable.empty()
                }

                return owner.interactor.searchRepo(
                    query: query,
                    sort: nil,
                    order: nil,
                    pageSize: nil,
                    page: nil
                )
                .catch { error in
                    // Map server errors to their descriptions and notify the view model's error relay
                    let serverError = (error as? ServerError) ?? .unknownError
                    owner.errorRelay.accept(serverError.errorDescription)
                    return Observable.empty()
                }
            }
            .share()

        searchTrigger
            .map { $0.items }
            .bind(to: repoListRelay)
            .disposed(by: disposeBag)

        searchQueryRelay
            .asObservable()
            .withUnretained(self)
            .subscribe { owner, queryString in
                owner.repoListRelay.accept([])
            }
            .disposed(by: disposeBag)
    }
}
