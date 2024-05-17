////
//  SearchRepoViewController.swift
//  GitHubRepo
//
//  Created by Jesse Chen on 2024/5/17.
//
//

import RxDataSources
import RxSwift
import UIKit

class SearchRepoViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    lazy var searchController: UISearchController = {
        let searchController = UISearchController()

        searchController.searchBar.returnKeyType = .search
        searchController.searchBar.placeholder = "請輸入關鍵字搜尋"
        searchController.searchBar.showsCancelButton = false
        searchController.hidesNavigationBarDuringPresentation = false

        searchController.searchBar.rx.text
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe { owner, searchString in
                owner.viewModel.inputs.searchQueryRelay.accept(searchString ?? "")
            }
            .disposed(by: disposeBag)

        searchController.searchBar.rx.searchButtonClicked
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.viewModel.inputs.searchTriggerRelay.accept(())
            }
            .disposed(by: disposeBag)

        return searchController
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()

        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.inputs.searchTriggerRelay)
            .disposed(by: disposeBag)

        return refreshControl
    }()

    private let disposeBag = DisposeBag()
    private let viewModel = SearchRepoViewModel()
    /// Data source for configuring table view sections and cells.
    private let dataSource = RxTableViewSectionedReloadDataSource<SearchRepoSection> { _, tableView, indexPath, item in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SearchRepoListCell.self), for: indexPath) as? SearchRepoListCell else {
            fatalError("Could not dequeue SearchRepoListCell")
        }

        cell.selectionStyle = .none
        cell.configureCell(with: item)

        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setUpTableView()
        configureNav()
    }

    /// Binds the view model outputs to UI elements.
    private func bindViewModel() {
        viewModel.outputs
            .repoListRelay
            .asObservable()
            .map { [SearchRepoSection(header: "", items: $0)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.outputs
            .repoListRelay
            .asObservable()
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.refreshControl.endRefreshing()
            }
            .disposed(by: disposeBag)

        viewModel.outputs.errorRelay
            .asObservable()
            .withUnretained(self)
            .subscribe { owner, errorMessage in
                print(errorMessage)
                owner.refreshControl.endRefreshing()
            }
            .disposed(by: disposeBag)

    }

    /// Sets up the table view
    private func setUpTableView() {
        tableView.register(cell: SearchRepoListCell.self)
        tableView.keyboardDismissMode = .onDrag
        tableView.addSubview(refreshControl)
    }

    private func configureNav() {
        title = "Repository Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }
}
