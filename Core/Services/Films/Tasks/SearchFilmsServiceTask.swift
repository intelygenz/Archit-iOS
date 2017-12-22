//  SearchFilmsServiceTask.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import Foundation
import Net
import RxSwift

class SearchFilmsServiceTask: ServiceTask {

    init(_ query: String, type: String?, page: Int) {
        super.init()
        requestBuilder = NetRequest.builder(NetworkServiceConstants.Host.api)?
            .addURLParameter(NetworkServiceConstants.Parameters.Search.title.rawValue, value: query)
            .addURLParameter(NetworkServiceConstants.Parameters.Search.page.rawValue, value: page)
        if let type = type {
            requestBuilder?.addURLParameter(NetworkServiceConstants.Parameters.Search.type.rawValue, value: NetworkServiceConstants.Values.Search.SearchType(rawValue: type))
        }
    }

}
