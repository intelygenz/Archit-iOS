//  FilmsController.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import Foundation
import Domain
import RxSwift

protocol FilmsControllerProtocol: BaseController {
    var films: Variable<[Film]> { get }
    var query: Variable<String> { get }
    var error: Variable<Error?> { get }
    var type: String { get }
    var page: Int { get }
    func search(_ query: String, type: String, page: Int)
    func loadMore()
}

class FilmsController: FilmsControllerProtocol {
    private let filmsInteractor: FilmsInteractorProtocol = FilmsInteractor()

    private(set) var films = Variable<[Film]>([])
    private(set) var query = Variable("Star Wars")
    private(set) var error = Variable<Error?>(nil)
    private(set) var type: String = "all"
    private(set) var page: Int = 1
    private var total: Int?

    private var disposeBag = DisposeBag()

    func load() {
        refresh()
    }

    func willDisappear(_ animated: Bool) {
        disposeBag = DisposeBag()
    }

    func search(_ query: String, type: String, page: Int = 1) {
        filmsInteractor.films(query, type: FilmsInteractorSearchType(rawValue: type), page: page)
            .subscribe(onSuccess: {
                self.query.value = query
                self.type = type
                self.page = page
                self.total = $0.total
                if page == 1 {
                    self.films.value = $0.films
                } else {
                    self.films.value.append(contentsOf: $0.films)
                }
                self.error.value = nil
            }, onError: {
                self.error.value = $0
            }).disposed(by: disposeBag)
    }

    func refresh() {
        search(query.value, type: type)
    }

    func loadMore() {
        guard let total = total, films.value.count < total else {
            return
        }
        search(query.value, type: type, page: page + 1)
    }

}
