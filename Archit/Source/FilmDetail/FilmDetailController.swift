//  FilmDetailController.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import Foundation
import Domain
import RxSwift

protocol FilmDetailControllerProtocol: BaseController {
    var film: Variable<Film?> { get }
    var error: Variable<Error?> { get }
}

class FilmDetailController: FilmDetailControllerProtocol {
    private let filmsInteractor: FilmsInteractorProtocol = FilmsInteractor()

    let film = Variable<Film?>(nil)
    let error = Variable<Error?>(nil)
    private var disposeBag = DisposeBag()

    func willAppear(_ animated: Bool) {
        refresh()
    }

    func willDisappear(_ animated: Bool) {
        self.disposeBag = DisposeBag()
    }

    func refresh() {
        guard let film = film.value else {
            return
        }

        let type = FilmsInteractorSearchType(rawValue: film.type)
        filmsInteractor.film(film.imdbID, type: type).subscribe(onSuccess: { film in
            self.film.value = film
            self.error.value = nil
        }, onError: { error in
            self.error.value = error
        }).disposed(by: disposeBag)
    }

}
