//  FilmsInteractor.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import Foundation
import Domain
import Core
import RxSwift

enum FilmsInteractorError: Error {
    case filmsError(message: String, underlying: Error?)

    public var localizedDescription: String {
        switch self {
        case .filmsError(let message, let underlying):
            guard let serviceTaskError = underlying as? ServiceTaskError else {
                guard let localizedDescription = underlying?.localizedDescription else {
                    return message
                }
                return localizedDescription
            }
            return serviceTaskError.localizedDescription
        }
    }
}

enum FilmsInteractorSearchType: String {
    case movie, series, episode
}

protocol FilmsInteractorProtocol {
    func film(_ imdbID: String, type: FilmsInteractorSearchType?) -> Single<Film>
    func films(_ query: String, type: FilmsInteractorSearchType?, page: Int) -> Single<(films: [Film], total: Int)>
}

class FilmsInteractor: BaseInteractor, FilmsInteractorProtocol {

    private let filmsService = FilmsService()

    func film(_ imdbID: String, type: FilmsInteractorSearchType?) -> Single<Film> {
        return filmsService.searchFilm(imdbID, type: type?.rawValue).observeOn(MainScheduler.instance)
    }

    func films(_ query: String, type: FilmsInteractorSearchType?, page: Int) -> Single<(films: [Film], total: Int)> {
        return filmsService.searchFilms(query, type: type?.rawValue, page: page).observeOn(MainScheduler.instance)
    }

}
