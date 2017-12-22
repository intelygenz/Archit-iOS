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
        let filmObservable: Single<FilmNetworkModel> = searchFilmServiceTask.execute()
        return filmObservable.map { film in
            try self.transformer.transform(source: film)
        }
    }

    public func searchFilms(_ query: String, type: String?, page: Int) -> Single<(films: [Film], total: Int)> {
        guard NetworkServiceConstants.Values.Search.PageRange.contains(page) else {
            return Single.error(ServiceTaskError.netError(message: "Service task pagination error.", underlying: nil))
        }
        let searchFilmsServiceTask = SearchFilmsServiceTask(query, type: type, page: page)
        let searchObservable: Single<FilmSearchNetworkModel> = searchFilmsServiceTask.execute()
        return searchObservable.map { search in
            guard let results = search.results, let total = search.total, let totalInt = Int(total) else {
                throw ServiceTaskError.parserError(message: search.error ?? "No results.", underlying: nil)
            }
            let films = try self.transformer.transform(source: results)
            return (films, totalInt)
        }
    }

}
