//
//  NetTaskMetrics+URLSessionTaskMetrics.swift
//  Net
//
//  Created by Alex Rupérez on 25/3/17.
//
//

import Foundation

@available(iOS 10.0, tvOS 10.0, watchOS 3.0, OSX 10.12, *)
extension NetTaskMetrics {

    public init(_ urlSessionTaskMetrics: URLSessionTaskMetrics, request: NetRequest? = nil, response: NetResponse? = nil) {
        var transactionMetrics = [NetTransactionMetrics]()
        #if !os(watchOS)
        transactionMetrics = urlSessionTaskMetrics.transactionMetrics.flatMap { transactionMetrics -> NetTransactionMetrics in
            NetTransactionMetrics(request: request, response: response, fetchStartDate: transactionMetrics.fetchStartDate, domainLookupStartDate: transactionMetrics.domainLookupStartDate, domainLookupEndDate: transactionMetrics.domainLookupEndDate, connectStartDate: transactionMetrics.connectStartDate, secureConnectionStartDate: transactionMetrics.secureConnectionStartDate, secureConnectionEndDate: transactionMetrics.secureConnectionEndDate, connectEndDate: transactionMetrics.connectEndDate, requestStartDate: transactionMetrics.requestStartDate, requestEndDate: transactionMetrics.requestEndDate, responseStartDate: transactionMetrics.responseStartDate, responseEndDate: transactionMetrics.responseEndDate, networkProtocolName: transactionMetrics.networkProtocolName, isProxyConnection: transactionMetrics.isProxyConnection, isReusedConnection: transactionMetrics.isReusedConnection, resourceFetchType: NetTransactionMetrics.NetResourceFetchType(rawValue: transactionMetrics.resourceFetchType.rawValue) ?? .unknown)
        }
        #endif
        self.init(transactionMetrics: transactionMetrics, taskInterval: urlSessionTaskMetrics.taskInterval.duration, redirectCount: urlSessionTaskMetrics.redirectCount)
    }
    
}
