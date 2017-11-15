//
//  NetTaskMetrics.swift
//  Net
//
//  Created by Alex Rupérez on 25/3/17.
//
//

import Foundation

public struct NetTaskMetrics {

    public struct NetTransactionMetrics {

        public enum NetResourceFetchType : Int {
            case unknown, networkLoad, serverPush, localCache
        }

        public let request: NetRequest?

        public let response: NetResponse?

        public let fetchStartDate: Date?

        public let domainLookupStartDate: Date?

        public let domainLookupEndDate: Date?

        public let connectStartDate: Date?

        public let secureConnectionStartDate: Date?

        public let secureConnectionEndDate: Date?

        public let connectEndDate: Date?

        public let requestStartDate: Date?

        public let requestEndDate: Date?

        public let responseStartDate: Date?

        public let responseEndDate: Date?

        public let networkProtocolName: String?

        public let isProxyConnection: Bool

        public let isReusedConnection: Bool

        public let resourceFetchType: NetResourceFetchType

    }

    public let transactionMetrics: [NetTransactionMetrics]

    public let taskInterval: TimeInterval

    public let redirectCount: Int
    
}
