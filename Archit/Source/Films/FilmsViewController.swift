//  FilmsViewController.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import UIKit
import Kingfisher
import Domain

class FilmsViewController: BaseViewController<FilmsController> {

    @IBOutlet private weak var tableView: UITableView!
    private let searchController = UISearchController(searchResultsController: nil)

    private var selectedFilm: Film? {
        guard let row = tableView.indexPathForSelectedRow?.row else {
            return nil
        }
        return controller.films[row]
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        controller = FilmsController(self)
    }

    private func configView() {
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        let searchBar = searchController.searchBar
        searchBar.delegate = self
        searchBar.scopeButtonTitles = ["All", "Movie", "Series", "Episode"]
        tableView.tableHeaderView = searchBar
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
        if splitViewController?.isCollapsed == false {
            performSegue(withIdentifier: "showDetail", sender: self)
        }
    }

    func reloadData() {
        if let refreshControl = tableView.refreshControl {
            refreshControl.endRefreshing()
            searchController.isActive = false
        } else {
            configView()
        }
        tableView.reloadData()
    }

    @objc private func refreshControlAction(_ sender: Any) {
        controller.refresh()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        searchController.isActive = false
        if segue.identifier == "showDetail",
            let navigationController = segue.destination as? BaseNavigationController,
            let filmViewController = navigationController.topViewController as? FilmDetailViewController {
            filmViewController.controller.film = selectedFilm
            filmViewController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            filmViewController.navigationItem.leftItemsSupplementBackButton = true
        }
    }

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let posters = indexPaths.flatMap { controller.films[$0.row].poster }
        ImagePrefetcher(urls: posters).start()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.films.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath)
        let film = controller.films[indexPath.row]
        if let cell = cell as? FilmCell {
            cell.inflate(imageUrl: film.poster, titleText: film.title, year: film.year)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if controller.films.count >= 10 && indexPath.row > controller.films.count * 8 / 10 {
            controller.loadMore()
        }
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.imageView?.kf.cancelDownloadTask()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let query = searchBar.text, !query.isEmpty {
            let scope = searchBar.scopeButtonTitles?[searchBar.selectedScopeButtonIndex].lowercased() ?? "all"
            controller.search(query, type: scope)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128.0
    }

}

extension FilmsViewController: UITableViewDataSourcePrefetching {}

extension FilmsViewController: UITableViewDataSource {}

extension FilmsViewController: UITableViewDelegate {}

extension FilmsViewController: UISearchBarDelegate {}
