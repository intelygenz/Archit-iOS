//  FilmsService.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import Foundation
import Domain

public protocol FilmsServiceProtocol: NetworkServiceProtocol {
    func searchFilm(_ imdbID: String, type: String?) throws -> Film
    func searchFilms(_ query: String, type: String?, page: Int) throws -> (films: [Film], total: Int)
}

public class FilmsService: NetworkService, FilmsServiceProtocol {

    private var transformer = FilmsNetworkTransformer()

    public func searchFilm(_ imdbID: String, type: String?) throws -> Film {
        let searchFilmServiceTask = SearchFilmServiceTask(imdbID, type: type)
        do {
            guard let film = try searchFilmServiceTask.execute() as? FilmNetworkModel else {
                throw ServiceTaskError.parserError(message: "Service task parsing error.", underlying: nil)
            }
            guard let result = transformer.transform(source: film) else {
                throw ServiceTaskError.parserError(message: "Not found.", underlying: nil)
            }
            return result
        } catch {
            guard let serviceTaskError = error as? ServiceTaskError else {
                throw NetworkServiceError.serviceError(message: "Service error.", underlying: ServiceTaskError.parserError(message: "Service task error.", underlying: nil))
            }
            throw NetworkServiceError.serviceError(message: "Can't find films.", underlying: serviceTaskError)
        }
    }

    public func searchFilms(_ query: String, type: String?, page: Int) throws -> (films: [Film], total: Int) {
        let searchFilmsServiceTask = SearchFilmsServiceTask(query, type: type, page: page)
        do {
            guard let search = try searchFilmsServiceTask.execute() as? FilmSearchNetworkModel else {
                throw ServiceTaskError.parserError(message: "Service task parsing error.", underlying: nil)
            }
            guard let results = search.results, let total = search.total, let totalInt = Int(total) else {
                throw ServiceTaskError.parserError(message: search.error ?? "No results.", underlying: nil)
            }
            return (transformer.transform(source: results), totalInt)
        } catch {
            guard let serviceTaskError = error as? ServiceTaskError else {
                throw NetworkServiceError.serviceError(message: "Service error.", underlying: ServiceTaskError.parserError(message: "Service task error.", underlying: nil))
            }
            throw NetworkServiceError.serviceError(message: "Can't find films.", underlying: serviceTaskError)
        }
    }

}
