//  ServiceTask.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import Foundation
import Net
import RxSwift

public class ServiceTask {
    private static let net: Net = {
        let net = NetURLSession()
        net.addRequestInterceptor { requestBuilder in
            requestBuilder.addURLParameter(NetworkServiceConstants.Parameters.key, value: NetworkServiceConstants.Values.key)
                .addURLParameter(NetworkServiceConstants.Parameters.format, value: NetworkServiceConstants.Values.Format.json.rawValue)
                .addURLParameter(NetworkServiceConstants.Parameters.version, value: NetworkServiceConstants.Values.version)
            log.debug(requestBuilder.build().debugDescription)
            return requestBuilder
        }
        net.addResponseInterceptor { responseBuilder in
            let response = responseBuilder.build()
            log.debug(response.debugDescription)
            do {
                if let responseObject: [AnyHashable: Any] = try response.object() {
                    log.verbose(responseObject)
                }
            } catch {}
            return responseBuilder
        }
        return net
    }()
    var requestBuilder: NetRequest.Builder!

    @discardableResult public func execute<D: Decodable>() -> Single<D> {
        assert(requestBuilder != nil, "You must define your requestBuilder in your subclass.")
        return ServiceTask.net.data(requestBuilder.build()).rx.response().decode()
    }
}
