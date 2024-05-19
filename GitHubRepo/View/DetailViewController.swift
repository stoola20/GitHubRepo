////
//  DetailViewController.swift
//  GitHubRepo
//
//  Created by Jesse Chen on 2024/5/19.
//

import RxSwift
import UIKit

class DetailViewController: UIViewController {
    // MARK: UIView

    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var fullNameLabel: UILabel!
    @IBOutlet var languageLabel: UILabel!
    @IBOutlet var starsLabel: UILabel!
    @IBOutlet var watchersLabel: UILabel!
    @IBOutlet var forksLabel: UILabel!
    @IBOutlet var issuesLabel: UILabel!

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
        configureNav()
        setUpUI()
        // Trigger fetching of repository details.
        viewModel.getRepoRelay.accept(())
    }
    
    /// Binds the view model's outputs to the view controller's UI elements.
    private func bindViewModel() {
        // Subscribe to detail repository updates and handle them.
        viewModel.outputs.detailRepoRelay
            .asObservable()
            .withUnretained(self)
            .subscribe { owner, detailRepo in
                owner.configureUI(with: detailRepo)
            }
            .disposed(by: disposeBag)
        
        // Subscribe to error messages and display them in an alert.
        viewModel.outputs.errorMessageRelay
            .asObservable()
            .withUnretained(self)
            .subscribe { owner, errorMessage in
                owner.showAlert(title: "Oops", message: errorMessage, confirm: {
                    owner.navigationController?.popViewController(animated: true)
                })
            }
            .disposed(by: disposeBag)
    }
    
    /// Configures the navigation bar for the view controller.
    private func configureNav() {
        // Set the title of the navigation bar to the repository owner's name.
        title = "\(viewModel.ownerRelay.value!)"
        // Set the tint color of the navigation bar to black.
        navigationController?.navigationBar.tintColor = .black
    }
    
    /// Sets up the initial UI configuration for the view controller.
    private func setUpUI() {
        avatarImageView.contentMode = .scaleAspectFill
        fullNameLabel.font = .systemFont(ofSize: 30, weight: .semibold)
        languageLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        
        starsLabel.textAlignment = .right
        watchersLabel.textAlignment = .right
        forksLabel.textAlignment = .right
        issuesLabel.textAlignment = .right
    }
    
    /// Configures the UI elements with the provided repository details.
    ///
    /// - Parameter repo: The detailed repository information.
    private func configureUI(with repo: DetailRepo) {
        avatarImageView.loadImage(repo.owner.avatarUrl)
        fullNameLabel.text = repo.fullName
        languageLabel.text = repo.language != nil
            ? "Written in \(repo.language!)"
            : "Null"
        starsLabel.text = "\(repo.stargazersCount) stars"
        watchersLabel.text = "\(repo.watchersCount) watchers"
        forksLabel.text = "\(repo.forksCount) forks"
        issuesLabel.text = "\(repo.openIssuesCount) open issues"
    }
}
