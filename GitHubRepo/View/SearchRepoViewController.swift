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

    /// Search controller for managing the search bar and search results.
    lazy var searchController: UISearchController = {
        let searchController = UISearchController()

        searchController.searchBar.returnKeyType = .search
        searchController.searchBar.placeholder = "請輸入關鍵字搜尋"
        searchController.searchBar.showsCancelButton = false
        searchController.hidesNavigationBarDuringPresentation = false

        // Handle text changes in the search bar.
        searchController.searchBar.rx.text
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe { owner, searchString in
                owner.viewModel.inputs.searchQueryRelay.accept(searchString ?? "")
            }
            .disposed(by: disposeBag)

        // Handle search button click.
        searchController.searchBar.rx.searchButtonClicked
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.viewModel.inputs.searchTriggerRelay.accept(())
            }
            .disposed(by: disposeBag)

        return searchController
    }()

    /// Refresh control for the table view.
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()

        // Bind the refresh control to the search trigger.
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
        // Bind the repository list to the table view.
        viewModel.outputs
            .repoListRelay
            .asObservable()
            .map { [SearchRepoSection(header: "", items: $0)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        // Handle the end of the refresh control's animation when new data is loaded.
        viewModel.outputs
            .repoListRelay
            .asObservable()
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.refreshControl.endRefreshing()
            }
            .disposed(by: disposeBag)

        // Display an alert in case of errors.
        viewModel.outputs.errorRelay
            .asObservable()
            .withUnretained(self)
            .subscribe { owner, errorMessage in
                owner.showAlert(title: "Oops!", message: errorMessage, confirm: {
                    owner.refreshControl.endRefreshing()
                })
            }
            .disposed(by: disposeBag)
    }

    /// Sets up the table view, including cell registration, keyboard dismissal mode, and adding refresh control.
    private func setUpTableView() {
        tableView.register(cell: SearchRepoListCell.self)
        tableView.keyboardDismissMode = .onDrag
        tableView.addSubview(refreshControl)

        // Handle item selection in the table view.
        tableView.rx
            .itemSelected
            .withUnretained(self)
            .subscribe { owner, indexPath in
                // Deselect the selected row with animation.
                owner.tableView.deselectRow(at: indexPath, animated: true)
            }
            .disposed(by: disposeBag)

        // Handle the selection of a specific model (SearchRepoItem) in the table view.
        tableView.rx
            .modelSelected(SearchRepoItem.self)
            .withUnretained(self)
            .subscribe { owner, repoItem in
                // Create an instance of DetailViewController with the selected repository's owner and name.
                let detailViewController = DetailViewController(
                    owner: repoItem.owner.login,
                    repo: repoItem.name
                )
                // Push the DetailViewController onto the navigation stack.
                owner.navigationController?.pushViewController(detailViewController, animated: true)
            }
            .disposed(by: disposeBag)
    }

    /// Configures the navigation bar for the view controller.
    private func configureNav() {
        title = "Repository Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }
}
