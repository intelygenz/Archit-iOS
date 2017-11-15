//  ServiceTask.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import Foundation
import Net

open class ServiceTask: ServiceTaskProtocol {
    private static let net: Net = {
        let net = NetURLSession()
        net.addRequestInterceptor { requestBuilder in
            return requestBuilder.addURLParameter(NetworkServiceConstants.Parameters.key, value: NetworkServiceConstants.Values.key)
                .addURLParameter(NetworkServiceConstants.Parameters.format, value: NetworkServiceConstants.Values.Format.json.rawValue)
                .addURLParameter(NetworkServiceConstants.Parameters.version, value: NetworkServiceConstants.Values.version)
        }
        return net
    }()
    var requestBuilder: NetRequest.Builder?
    private var task: NetTask?

    @discardableResult open func execute() throws -> Any? {
        guard let request = requestBuilder?.build() else {
            throw ServiceTaskError.netError(message: "Service task request missing.", underlying: nil)
        }
        task = ServiceTask.net.data(request)
        guard let task = task else {
            throw ServiceTaskError.netError(message: "Service task building error.", underlying: nil)
        }
        var response: NetResponse
        do {
            response = try task.sync()
        } catch {
            guard let serviceTaskError = error as? ServiceTaskError else {
                throw ServiceTaskError.netError(message: "Network error.", underlying: error)
            }
            throw serviceTaskError
        }
        do {
            return try parse(response)
        } catch {
            guard let serviceTaskError = error as? ServiceTaskError else {
                throw ServiceTaskError.parserError(message: "Parser error.", underlying: error)
            }
            throw serviceTaskError
        }
    }

    @discardableResult open func parse(_ response: NetResponse) throws -> Any? {
        return try response.object() as [AnyHashable: Any]
    }

    open func cancel() {
        task?.cancel()
    }

}

extension ServiceTask: Hashable {
    public var hashValue: Int {
        return task?.identifier ?? NSNotFound
    }

    public static func == (lhs: ServiceTask, rhs: ServiceTask) -> Bool {
        return lhs.hashValue != NSNotFound && lhs.hashValue == rhs.hashValue
    }

}

