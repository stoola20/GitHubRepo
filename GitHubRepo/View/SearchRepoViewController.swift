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
        viewModel.inputs.searchQueryRelay.accept("apple")
        viewModel.inputs.searchRepo()
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
    }
}
