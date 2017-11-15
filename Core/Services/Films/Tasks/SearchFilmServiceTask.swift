//  SearchFilmServiceTask.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import Foundation
import Net

class SearchFilmServiceTask: ServiceTask {

    let imdbID: String
    let type: String?

    init(_ imdbID: String, type: String?) {
        self.imdbID = imdbID
        self.type = type
    }

    override func parse(_ response: NetResponse) throws -> Any? {
        return try response.decode() as FilmNetworkModel
    }

    override func execute() throws -> Any? {
        requestBuilder = NetRequest.builder(NetworkServiceConstants.Host.api)?
            .addURLParameter(NetworkServiceConstants.Parameters.Search.imdbID.rawValue, value: imdbID)
            .addURLParameter(NetworkServiceConstants.Parameters.Search.plot.rawValue, value: NetworkServiceConstants.Values.Search.Plot.full.rawValue)
        if let type = type {
            requestBuilder?.addURLParameter(NetworkServiceConstants.Parameters.Search.type.rawValue, value: NetworkServiceConstants.Values.Search.SearchType(rawValue: type))
        }
        return try super.execute()
    }

}
