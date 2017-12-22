//
//  URLSessionConfiguration+Build.swift
//  Net
//
//  Created by Alex Rupérez on 4/12/17.
//

import Foundation

extension URLSessionConfiguration {

    public class Builder {

        public enum NetMultipathServiceType: Int {
            case none, handover, interactive, aggregate
        }

        public private(set) var cache: NetRequest.NetCachePolicy?

        public private(set) var requestTimeout: TimeInterval?

        public private(set) var resourceTimeout: TimeInterval?

        public private(set) var serviceType: NetRequest.NetServiceType?

        public private(set) var allowsCellularAccess: Bool?

        public private(set) var waitsForConnectivity: Bool?

        public private(set) var discretionary: Bool?

        public private(set) var containerIdentifier: String?

        public private(set) var sendsLaunchEvents: Bool?

        public private(set) var proxyDictionary: [AnyHashable : Any]?

        public private(set) var minimumTLSSupported: SSLProtocol?

        public private(set) var maximumTLSSupported: SSLProtocol?

        public private(set) var usePipelining: Bool?

        public private(set) var handleCookies: Bool?

        public private(set) var acceptPolicy: HTTPCookie.AcceptPolicy?

        public private(set) var headers: [String : String]?

        public private(set) var maximumConnections: Int?

        public private(set) var cookieStorage: HTTPCookieStorage?

        public private(set) var credentialStorage: URLCredentialStorage?

        public private(set) var urlCache: URLCache?

        public private(set) var extendedBackgroundIdle: Bool?

        public private(set) var protocolClasses: [Swift.AnyClass]?

        public private(set) var multipathServiceType: NetMultipathServiceType?

        public init(_ configuration: URLSessionConfiguration? = nil) {

            cache = NetRequest.NetCachePolicy(rawValue: configuration?.requestCachePolicy.rawValue ?? 0)

            requestTimeout = configuration?.timeoutIntervalForRequest

            resourceTimeout = configuration?.timeoutIntervalForResource

            serviceType = NetRequest.NetServiceType(rawValue: configuration?.networkServiceType.rawValue ?? 0)

            allowsCellularAccess = configuration?.allowsCellularAccess

            if #available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *) {
                waitsForConnectivity = configuration?.waitsForConnectivity
            }

            discretionary = configuration?.isDiscretionary

            containerIdentifier = configuration?.sharedContainerIdentifier

            #if !os(macOS)
                if #available(iOS 7.0, tvOS 9.0, watchOS 2.0, *) {
                    sendsLaunchEvents = configuration?.sessionSendsLaunchEvents
                }
            #endif

            proxyDictionary = configuration?.connectionProxyDictionary

            minimumTLSSupported = configuration?.tlsMinimumSupportedProtocol

            maximumTLSSupported = configuration?.tlsMaximumSupportedProtocol

            usePipelining = configuration?.httpShouldUsePipelining

            handleCookies = configuration?.httpShouldSetCookies

            acceptPolicy = configuration?.httpCookieAcceptPolicy

            headers = configuration?.httpAdditionalHeaders as? [String : String]

            maximumConnections = configuration?.httpMaximumConnectionsPerHost

            cookieStorage = configuration?.httpCookieStorage

            credentialStorage = configuration?.urlCredentialStorage

            urlCache = configuration?.urlCache

            if #available(iOS 9.0, tvOS 9.0, watchOS 2.0, macOS 10.11, *) {
                extendedBackgroundIdle = configuration?.shouldUseExtendedBackgroundIdleMode
            }

            protocolClasses = configuration?.protocolClasses

            #if os(iOS)
                if #available(iOS 11.0, *) {
                    self.multipathServiceType = NetMultipathServiceType(rawValue: configuration?.multipathServiceType.rawValue ?? 0)
                }
            #endif
        }

        @discardableResult open func setCache(_ cachePolicy: NetRequest.NetCachePolicy?) -> Self {
            self.cache = cache
            return self
        }

        @discardableResult open func setRequestTimeout(_ requestTimeout: TimeInterval?) -> Self {
            self.requestTimeout = requestTimeout
            return self
        }

        @discardableResult open func setResourceTimeout(_ resourceTimeout: TimeInterval?) -> Self {
            self.resourceTimeout = resourceTimeout
            return self
        }

        @discardableResult open func setServiceType(_ serviceType: NetRequest.NetServiceType?) -> Self {
            self.serviceType = serviceType
            return self
        }

        @discardableResult open func setAllowsCellularAccess(_ allowsCellularAccess: Bool?) -> Self {
            self.allowsCellularAccess = allowsCellularAccess
            return self
        }

        @discardableResult open func setWaitsForConnectivity(_ waitsForConnectivity: Bool?) -> Self {
            self.waitsForConnectivity = waitsForConnectivity
            return self
        }

        @discardableResult open func setDiscretionary(_ discretionary: Bool?) -> Self {
            self.discretionary = discretionary
            return self
        }

        @discardableResult open func setContainerIdentifier(_ containerIdentifier: String?) -> Self {
            self.containerIdentifier = containerIdentifier
            return self
        }

        @discardableResult open func setSendsLaunchEvents(_ sendsLaunchEvents: Bool?) -> Self {
            self.sendsLaunchEvents = sendsLaunchEvents
            return self
        }

        @discardableResult open func setProxyDictionary(_ proxyDictionary: [AnyHashable : Any]?) -> Self {
            self.proxyDictionary = proxyDictionary
            return self
        }

        @discardableResult open func setMinimumTLSSupported(_ minimumTLSSupported: SSLProtocol?) -> Self {
            self.minimumTLSSupported = minimumTLSSupported
            return self
        }

        @discardableResult open func setMaximumTLSSupported(_ maximumTLSSupported: SSLProtocol?) -> Self {
            self.maximumTLSSupported = maximumTLSSupported
            return self
        }

        @discardableResult open func setUsePipelining(_ usePipelining: Bool?) -> Self {
            self.usePipelining = usePipelining
            return self
        }

        @discardableResult open func setHandleCookies(_ handleCookies: Bool?) -> Self {
            self.handleCookies = handleCookies
            return self
        }

        @discardableResult open func setAcceptPolicy(_ acceptPolicy: HTTPCookie.AcceptPolicy?) -> Self {
            self.acceptPolicy = acceptPolicy
            return self
        }

        @discardableResult open func setHeaders(_ headers: [String : String]?) -> Self {
            self.headers = headers
            return self
        }

        @discardableResult open func addHeader(_ key: String, value: String?) -> Self {
            if self.headers == nil {
                setHeaders([:])
            }
            self.headers?[key] = value
            return self
        }

        @discardableResult open func setMaximumConnections(_ maximumConnections: Int?) -> Self {
            self.maximumConnections = maximumConnections
            return self
        }

        @discardableResult open func setCookieStorage(_ cookieStorage: HTTPCookieStorage?) -> Self {
            self.cookieStorage = cookieStorage
            return self
        }

        @discardableResult open func setCredentialStorage(_ credentialStorage: URLCredentialStorage?) -> Self {
            self.credentialStorage = credentialStorage
            return self
        }

        @discardableResult open func setURLCache(_ urlCache: URLCache?) -> Self {
            self.urlCache = urlCache
            return self
        }

        @discardableResult open func setExtendedBackgroundIdle(_ extendedBackgroundIdle: Bool?) -> Self {
            self.extendedBackgroundIdle = extendedBackgroundIdle
            return self
        }

        @discardableResult open func setProtocolClasses(_ protocolClasses: [Swift.AnyClass]?) -> Self {
            self.protocolClasses = protocolClasses
            return self
        }

        @discardableResult open func setMultipathServiceType(_ multipathServiceType: NetMultipathServiceType?) -> Self {
            self.multipathServiceType = multipathServiceType
            return self
        }

        public func `default`() -> URLSessionConfiguration {
            return .default(self)
        }

        public func ephemeral() -> URLSessionConfiguration {
            return .ephemeral(self)
        }

        public func background(_ identifier: String) -> URLSessionConfiguration {
            return .background(self, identifier: identifier)
        }

    }

    public func builder() -> Builder {
        return URLSessionConfiguration.builder(self)
    }

    public static func builder(_ configuration: URLSessionConfiguration? = nil) -> Builder {
        return Builder(configuration)
    }

    static func `default`(_ builder: Builder) -> URLSessionConfiguration {
        return custom(builder, configuration: .default)
    }

    static func ephemeral(_ builder: Builder) -> URLSessionConfiguration {
        return custom(builder, configuration: .ephemeral)
    }

    static func background(_ builder: Builder, identifier: String) -> URLSessionConfiguration {
        return custom(builder, configuration: .background(withIdentifier: identifier))
    }

    private static func custom(_ builder: Builder, configuration: URLSessionConfiguration) -> URLSessionConfiguration {

        if let requestCachePolicy = URLRequest.CachePolicy(rawValue: builder.cache?.rawValue ?? 0) {
            configuration.requestCachePolicy = requestCachePolicy
        }

        if let timeoutIntervalForRequest = builder.requestTimeout {
            configuration.timeoutIntervalForRequest = timeoutIntervalForRequest
        }

        if let timeoutIntervalForResource = builder.resourceTimeout {
            configuration.timeoutIntervalForResource = timeoutIntervalForResource
        }

        if let networkServiceType = URLRequest.NetworkServiceType(rawValue: builder.serviceType?.rawValue ?? 0) {
            configuration.networkServiceType = networkServiceType
        }

        if let allowsCellularAccess = builder.allowsCellularAccess {
            configuration.allowsCellularAccess = allowsCellularAccess
        }

        if #available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *), let waitsForConnectivity = builder.waitsForConnectivity {
            configuration.waitsForConnectivity = waitsForConnectivity
        }

        if let isDiscretionary = builder.discretionary {
            configuration.isDiscretionary = isDiscretionary
        }

        configuration.sharedContainerIdentifier = builder.containerIdentifier

        #if !os(macOS)
            if #available(iOS 7.0, tvOS 9.0, watchOS 2.0, *), let sessionSendsLaunchEvents = builder.sendsLaunchEvents {
                configuration.sessionSendsLaunchEvents = sessionSendsLaunchEvents
            }
        #endif

        configuration.connectionProxyDictionary = builder.proxyDictionary

        if let tlsMinimumSupportedProtocol = builder.minimumTLSSupported {
            configuration.tlsMinimumSupportedProtocol = tlsMinimumSupportedProtocol
        }

        if let tlsMaximumSupportedProtocol = builder.maximumTLSSupported {
            configuration.tlsMaximumSupportedProtocol = tlsMaximumSupportedProtocol
        }

        if let httpShouldUsePipelining = builder.usePipelining {
            configuration.httpShouldUsePipelining = httpShouldUsePipelining
        }

        if let httpShouldSetCookies = builder.handleCookies {
            configuration.httpShouldSetCookies = httpShouldSetCookies
        }

        if let httpCookieAcceptPolicy = builder.acceptPolicy {
            configuration.httpCookieAcceptPolicy = httpCookieAcceptPolicy
        }

        configuration.httpAdditionalHeaders = builder.headers

        if let httpMaximumConnectionsPerHost = builder.maximumConnections {
            configuration.httpMaximumConnectionsPerHost = httpMaximumConnectionsPerHost
        }

        configuration.httpCookieStorage = builder.cookieStorage

        configuration.urlCredentialStorage = builder.credentialStorage

        configuration.urlCache = builder.urlCache

        if #available(iOS 9.0, tvOS 9.0, watchOS 2.0, macOS 10.11, *), let shouldUseExtendedBackgroundIdleMode = builder.extendedBackgroundIdle {
            configuration.shouldUseExtendedBackgroundIdleMode = shouldUseExtendedBackgroundIdleMode
        }

        configuration.protocolClasses = builder.protocolClasses

        #if os(iOS)
            if #available(iOS 11.0, *), let multipathServiceType = URLSessionConfiguration.MultipathServiceType(rawValue: builder.multipathServiceType?.rawValue ?? 0) {
                configuration.multipathServiceType = multipathServiceType
            }
        #endif

        return configuration
    }

}
