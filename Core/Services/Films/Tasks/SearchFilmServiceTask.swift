//  SearchFilmServiceTask.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import Foundation
import Net
import RxSwift

class SearchFilmServiceTask: ServiceTask {

    init(_ imdbID: String, type: String?) {
        super.init()
        requestBuilder = NetRequest.builder(NetworkServiceConstants.Host.api)?
            .addURLParameter(NetworkServiceConstants.Parameters.Search.imdbID.rawValue, value: imdbID)
            .addURLParameter(NetworkServiceConstants.Parameters.Search.plot.rawValue, value: NetworkServiceConstants.Values.Search.Plot.full.rawValue)
        if let type = type {
            requestBuilder?.addURLParameter(NetworkServiceConstants.Parameters.Search.type.rawValue, value: NetworkServiceConstants.Values.Search.SearchType(rawValue: type))
        }
    }

}
