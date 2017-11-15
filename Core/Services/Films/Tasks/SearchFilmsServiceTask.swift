//  SearchFilmsServiceTask.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import Foundation
import Net

class SearchFilmsServiceTask: ServiceTask {

    let query: String
    let type: String?
    let page: Int

    init(_ query: String, type: String?, page: Int) {
        self.query = query
        self.type = type
        self.page = page
    }

    override func parse(_ response: NetResponse) throws -> Any? {
        return try response.decode() as FilmSearchNetworkModel
    }

    override func execute() throws -> Any? {
        guard NetworkServiceConstants.Values.Search.PageRange.contains(page) else {
            throw ServiceTaskError.netError(message: "Service task pagination error.", underlying: nil)
        }
        requestBuilder = NetRequest.builder(NetworkServiceConstants.Host.api)?
            .addURLParameter(NetworkServiceConstants.Parameters.Search.title.rawValue, value: query)
            .addURLParameter(NetworkServiceConstants.Parameters.Search.page.rawValue, value: page)
        if let type = type {
            requestBuilder?.addURLParameter(NetworkServiceConstants.Parameters.Search.type.rawValue, value: NetworkServiceConstants.Values.Search.SearchType(rawValue: type))
        }
        return try super.execute()
    }

}
