//  FilmsViewController.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import UIKit
import Kingfisher
import Domain
import RxSwift
import RxCocoa

class FilmsViewController: BaseViewController<FilmsController> {

    @IBOutlet private weak var tableView: UITableView!
    private let searchController = UISearchController(searchResultsController: nil)
    private let disposeBag = DisposeBag()

    private var selectedFilm: Film? {
        guard let row = tableView.indexPathForSelectedRow?.row, row < controller.films.value.count else {
            return nil
        }
        return controller.films.value[row]
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        controller = FilmsController()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        bindUiEvents()
        bindViewModel()
    }

    private func configView() {
        tableView.prefetchDataSource = self
        tableView.tableFooterView = UIView()
        tableView.refreshControl = UIRefreshControl()
        let searchBar = searchController.searchBar
        searchBar.delegate = self
        searchBar.scopeButtonTitles = ["All", "Movie", "Series", "Episode"]
        tableView.tableHeaderView = searchBar
    }

    private func bindUiEvents() {
        tableView.rx.setDelegate(self).disposed(by: disposeBag)

        tableView.rx.willDisplayCell.subscribe(onNext: { event in
            if self.controller.films.value.count >= 10 && event.indexPath.row > self.controller.films.value.count * 8 / 10 {
                self.controller.loadMore()
            }
        }).disposed(by: disposeBag)

        tableView.rx.didEndDisplayingCell.subscribe(onNext: { event in
            event.cell.imageView?.kf.cancelDownloadTask()
        }).disposed(by: disposeBag)

        tableView.rx.itemSelected.subscribe(onNext: { indexPath in
            self.tableView.deselectRow(at: indexPath, animated: true)
        }).disposed(by: disposeBag)

        tableView.refreshControl?.rx.controlEvent(.valueChanged).subscribe(onNext: {
            self.controller.refresh()
        }).disposed(by: disposeBag)
    }

    private func bindViewModel() {
        controller.films.asObservable().subscribe(onNext: { films in
            self.tableView.refreshControl?.endRefreshing()
            self.searchController.isActive = false
            if films.count > 0 {
                self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
            if self.splitViewController?.isCollapsed == false {
                    self.performSegue(withIdentifier: "showDetail", sender: self)
                }
            }
        }).disposed(by: disposeBag)

        controller.films.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: "FilmCell", cellType: FilmCell.self)) { _, film, cell in
                cell.configure(imageUrl: film.poster, title: film.title, year: film.year)
            }.disposed(by: disposeBag)

        controller.query.asObservable().bind(to: rx.title).disposed(by: disposeBag)

        controller.error.asObservable().subscribe(onNext: { error in
            if let localizedDescription = error?.localizedDescription {
                self.showAlert(localizedDescription)
            }
        }).disposed(by: disposeBag)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        searchController.isActive = false
        if segue.identifier == "showDetail",
            let navigationController = segue.destination as? BaseNavigationController,
            let filmViewController = navigationController.topViewController as? FilmDetailViewController {
            filmViewController.controller.film.value = selectedFilm
            filmViewController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            filmViewController.navigationItem.leftItemsSupplementBackButton = true
        }
    }

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let posters = indexPaths.flatMap { controller.films.value[$0.row].poster }
        ImagePrefetcher(urls: posters).start()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let query = searchBar.text, !query.isEmpty {
            let scope = searchBar.scopeButtonTitles?[searchBar.selectedScopeButtonIndex].lowercased() ?? "all"
            controller.search(query, type: scope)
        }
    }

}

extension FilmsViewController: UITableViewDataSourcePrefetching {}

extension FilmsViewController: UIScrollViewDelegate {}

extension FilmsViewController: UISearchBarDelegate {}
