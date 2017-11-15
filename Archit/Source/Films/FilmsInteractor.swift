//  FilmsInteractor.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import Foundation
import Kommander
import Domain
import Core

enum FilmsInteractorError: Error {
    case filmsError(message: String, underlying: Error?)

    public var localizedDescription: String {
        switch self {
        case .filmsError(let message, let underlying):
            guard let serviceError = underlying as? NetworkServiceError else {
                guard let localizedDescription = underlying?.localizedDescription else {
                    return message
                }
                return localizedDescription
            }
            return serviceError.localizedDescription
        }
    }
}

typealias FilmsInteractorFilmBlock = (Film) -> Void
typealias FilmsInteractorFilmsBlock = ([Film], Int) -> Void
typealias FilmsInteractorErrorBlock = (FilmsInteractorError) -> Void

enum FilmsInteractorSearchType: String {
    case movie, series, episode
}

protocol FilmsInteractorProtocol {
    func film(_ imdbID: String, type: FilmsInteractorSearchType?, onSuccess: FilmsInteractorFilmBlock?, onError: FilmsInteractorErrorBlock?) -> Kommand<Film>
    func films(_ query: String, type: FilmsInteractorSearchType?, page: Int, onSuccess: FilmsInteractorFilmsBlock?, onError: FilmsInteractorErrorBlock?) -> Kommand<(films: [Film], total: Int)>
}

class FilmsInteractor: BaseInteractor, FilmsInteractorProtocol {

    private static let kommander = Kommander.default
    private let filmsService = FilmsService()

    func film(_ imdbID: String, type: FilmsInteractorSearchType?, onSuccess: FilmsInteractorFilmBlock?, onError: FilmsInteractorErrorBlock?) -> Kommand<Film> {
        return FilmsInteractor.kommander.makeKommand({
            return try self.filmsService.searchFilm(imdbID, type: type?.rawValue)
        }).onSuccess({ film in
            onSuccess?(film)
        }).onError({ error in
            onError?(.filmsError(message: "Error requesting films.", underlying: error))
        })
    }

    func films(_ query: String, type: FilmsInteractorSearchType?, page: Int, onSuccess: FilmsInteractorFilmsBlock?, onError: FilmsInteractorErrorBlock?) -> Kommand<(films: [Film], total: Int)> {
        return FilmsInteractor.kommander.makeKommand({
            return try self.filmsService.searchFilms(query, type: type?.rawValue, page: page)
        }).onSuccess({ result in
            onSuccess?(result.films, result.total)
        }).onError({ error in
            onError?(.filmsError(message: "Error requesting films.", underlying: error))
        })
    }

}
