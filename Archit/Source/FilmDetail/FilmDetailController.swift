//  FilmDetailController.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import Foundation
import Domain
import Kommander

protocol FilmDetailControllerProtocol: BaseController {
    var film: Film? { get }
}

class FilmDetailController: FilmDetailControllerProtocol {
    weak var viewController: FilmDetailViewController?
    var film: Film? {
        didSet {
            viewController?.reloadData()
        }
    }
    private let filmsInteractor: FilmsInteractorProtocol = FilmsInteractor()
    private weak var filmSearchKommand: Kommand<Film>?

    convenience init(_ viewController: FilmDetailViewController, film: Film) {
        self.init(viewController)
        self.film = film
    }

    required init(_ viewController: FilmDetailViewController) {
        self.viewController = viewController
    }

    func willAppear(_ animated: Bool) {
        refresh()
    }

    func willDisappear(_ animated: Bool) {
        filmSearchKommand?.cancel()
    }

    func refresh() {
        guard let imdbID = film?.imdbID, let type = film?.type else {
            return
        }
        filmSearchKommand = filmsInteractor.film(imdbID, type: FilmsInteractorSearchType(rawValue: type), onSuccess: { film in
            self.film = film
        }, onError: { error in
            self.viewController?.showAlert(error.localizedDescription, completion: {
                self.viewController?.reloadData()
            })
        }).execute()
    }

}
