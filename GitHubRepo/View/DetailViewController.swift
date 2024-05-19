////
//  DetailViewController.swift
//  GitHubRepo
//
//  Created by Jesse Chen on 2024/5/19.
//

import RxSwift
import UIKit

class DetailViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    let viewModel: DetailViewModel
    
    /// Initializes the view controller with a view model, repository owner, and repository name.
    /// - Parameters:
    ///   - viewModel: The view model for this view controller, defaulting to a new `DetailViewModel` instance.
    ///   - owner: The owner of the repository.
    ///   - repo: The name of the repository.
    init(viewModel: DetailViewModel = DetailViewModel(), owner: String, repo: String) {
        self.viewModel = viewModel
        super.init(nibName: "DetailViewController", bundle: nil)
        self.viewModel.inputs.ownerRelay.accept(owner)
        self.viewModel.inputs.repoRelay.accept(repo)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        // Trigger fetching of repository details.
        viewModel.getRepoRelay.accept(())
    }
    
    /// Binds the view model's outputs to the view controller's UI elements.
    private func bindViewModel() {
        // Subscribe to detail repository updates and handle them.
        viewModel.outputs.detailRepoRelay
            .asObservable()
            .withUnretained(self)
            .subscribe { _, detailRepo in
                print(detailRepo)
            }
            .disposed(by: disposeBag)
        
        // Subscribe to error messages and display them in an alert.
        viewModel.outputs.errorMessageRelay
            .asObservable()
            .withUnretained(self)
            .subscribe { owner, errorMessage in
                owner.showAlert(title: "Oops", message: errorMessage)
            }
            .disposed(by: disposeBag)
    }
}
