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
                owner.viewModel.inputs.searchRepo()
            }
            .disposed(by: disposeBag)

        return searchController
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

        viewModel.outputs.errorRelay
            .asObservable()
            .subscribe { errorMessage in
                print(errorMessage)
            }
            .disposed(by: disposeBag)
    }

    /// Sets up the table view
    private func setUpTableView() {
        tableView.register(cell: SearchRepoListCell.self)
        tableView.keyboardDismissMode = .onDrag
    }

    private func configureNav() {
        title = "Repository Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.hidesSearchBarWhenScrolling = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        view.endEditing(true)
    }
}
