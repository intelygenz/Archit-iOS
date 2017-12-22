//  FilmsService.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import Foundation
import Domain
import RxSwift

public protocol FilmsServiceProtocol {
    func searchFilm(_ imdbID: String, type: String?) -> Single<Film>
    func searchFilms(_ query: String, type: String?, page: Int) -> Single<(films: [Film], total: Int)>
}

public class FilmsService: FilmsServiceProtocol {

    private var transformer = FilmsNetworkTransformer()

    public init() {}

    public func searchFilm(_ imdbID: String, type: String?) -> Single<Film> {
        let searchFilmServiceTask = SearchFilmServiceTask(imdbID, type: type)
        let film: Single<FilmNetworkModel> = searchFilmServiceTask.execute()
        return film.flatMap { Single.just( try self.transformer.transform(source: $0)) }
    }

    public func searchFilms(_ query: String, type: String?, page: Int) -> Single<(films: [Film], total: Int)> {
        guard NetworkServiceConstants.Values.Search.PageRange.contains(page) else {
            return Single.error(ServiceTaskError.netError(message: "Service task pagination error.", underlying: nil))
        }
        let searchFilmsServiceTask = SearchFilmsServiceTask(query, type: type, page: page)
        let search: Single<FilmSearchNetworkModel> = searchFilmsServiceTask.execute()
        return search.flatMap { Single.just(( try self.transformer.transform(source: $0.results ?? []), Int($0.total ?? "") ?? 0)) }
    }

}
