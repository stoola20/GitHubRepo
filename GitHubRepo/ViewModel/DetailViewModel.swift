////
//  DetailViewModel.swift
//  GitHubRepo
//
//  Created by Jesse Chen on 2024/5/19.
//

import Foundation
import RxRelay
import RxSwift

/// Protocol defining the inputs required for the search repository view model.
protocol DetailViewModelInputs {
    /// Relay to hold the owner of the repository.
    var ownerRelay: BehaviorRelay<String?> { get }
    /// Relay to hold the repository name.
    var repoRelay: BehaviorRelay<String?> { get }
    /// Relay to trigger fetching of repository details.
    var getRepoRelay: PublishRelay<Void> { get }
}

/// Protocol defining the outputs provided by the search repository view model.
protocol DetailViewModelOutputs {
    /// Relay to emit the detailed repository information.
    var detailRepoRelay: PublishRelay<DetailRepo> { get }
    /// Relay to emit error messages.
    var errorMessageRelay: PublishRelay<String> { get }
}

/// Protocol combining both inputs and outputs of the search repository view model.
protocol DetailViewModelType {
    var inputs: DetailViewModelInputs { get }
    var outputs: DetailViewModelOutputs { get }
}

class DetailViewModel: DetailViewModelInputs, DetailViewModelOutputs, DetailViewModelType {
    // MARK: Type

    var inputs: DetailViewModelInputs { self }
    var outputs: DetailViewModelOutputs { self }
    
    private let disposeBag = DisposeBag()
    private let interactor: SearchInteractorProtocol
    
    // MARK: Inputs

    var ownerRelay: BehaviorRelay<String?> = .init(value: nil)
    var repoRelay: BehaviorRelay<String?> = .init(value: nil)
    var getRepoRelay: PublishRelay<Void> = .init()
    
    // MARK: Outputs

    var detailRepoRelay: PublishRelay<DetailRepo> = .init()
    var errorMessageRelay: PublishRelay<String> = .init()
    
    init(interactor: SearchInteractorProtocol = SearchInteractor()) {
        self.interactor = interactor
        
        // Observable that triggers fetching repository details when `getRepoRelay` emits.
        let getRepoTrigger = getRepoRelay
            .asObservable()
            .withUnretained(self)
            .flatMap { owner, _ -> Observable<DetailRepo> in
                // Guard to ensure owner and repository name are non-nil.
                guard let ownerName = owner.ownerRelay.value,
                      let repo = owner.repoRelay.value else {
                    return .empty()
                }
                
                // Fetch repository details from interactor.
                return owner.interactor.getRepo(owner: ownerName, repo: repo)
                    .catch { error in
                        // Map error to human readable error message and emit via `errorMessageRelay`.
                        let serverError = error as? ServerError ?? .unknownError
                        owner.errorMessageRelay.accept(serverError.errorDescription)
                        return .empty()
                    }
            }
            .share()
        
        // Bind fetched repository details to `detailRepoRelay`.
        getRepoTrigger
            .bind(to: detailRepoRelay)
            .disposed(by: disposeBag)
    }
}
