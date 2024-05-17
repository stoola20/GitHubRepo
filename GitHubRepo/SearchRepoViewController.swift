////
//  SearchRepoViewController.swift
//  GitHubRepo
//
//  Created by Jesse Chen on 2024/5/17.
//
//

import RxSwift
import UIKit

class SearchRepoViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let viewModel = SearchRepoViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        viewModel.inputs.searchQueryRelay.accept("apple")
        viewModel.inputs.searchRepo()
    }

    /// Binds the view model outputs to UI elements.
    func bindViewModel() {
        viewModel.outputs.repoListRelay
            .asObservable()
            .subscribe { repoList in
                print(repoList)
            }
            .disposed(by: disposeBag)

        viewModel.outputs.errorRelay
            .asObservable()
            .subscribe { errorMessage in
                print(errorMessage)
            }
            .disposed(by: disposeBag)
    }
}
