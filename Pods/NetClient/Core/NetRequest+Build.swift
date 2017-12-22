//
//  NetRequest+Build.swift
//  Net
//
//  Created by Alex Rupérez on 25/3/17.
//
//

import Foundation

extension NetRequest {

    public class Builder {

        public private(set) var url: URL

        public private(set) var cache: NetRequest.NetCachePolicy?

        public private(set) var timeout: TimeInterval?

        public private(set) var mainDocumentURL: URL?

        public private(set) var serviceType: NetRequest.NetServiceType?

        public private(set) var contentType: NetContentType?

        public private(set) var contentLength: NetContentLength?

        public private(set) var accept: NetContentType?

        public private(set) var acceptEncoding: [NetContentEncoding]?

        public private(set) var cacheControl: [NetCacheControl]?

        public private(set) var allowsCellularAccess: Bool?

        public private(set) var method: NetRequest.NetMethod?

        public private(set) var headers: [String : String]?

        public private(set) var body: Data?

        public private(set) var bodyStream: InputStream?

        public private(set) var handleCookies: Bool?

        public private(set) var usePipelining: Bool?

        public private(set) var authorization: NetAuthorization?

        public init(_ netRequest: NetRequest) {
            url = netRequest.url
            cache = netRequest.cache
            timeout = netRequest.timeout
            mainDocumentURL = netRequest.mainDocumentURL
            serviceType = netRequest.serviceType
            contentType = netRequest.contentType
            contentLength = netRequest.contentLength
            accept = netRequest.accept
            acceptEncoding = netRequest.acceptEncoding
            cacheControl = netRequest.cacheControl
            allowsCellularAccess = netRequest.allowsCellularAccess
            method = netRequest.httpMethod != .GET ? netRequest.httpMethod : nil
            headers = netRequest.headers
            body = netRequest.body
            bodyStream = netRequest.bodyStream
            handleCookies = netRequest.handleCookies
            usePipelining = netRequest.usePipelining
            authorization = netRequest.authorization
        }

        public convenience init?(_ urlRequest: URLRequest) {
            guard let netRequest = urlRequest.netRequest else {
                return nil
            }
            self.init(netRequest)
        }

        public init(_ url: URL) {
            self.url = url
        }

        public convenience init?(_ urlString: String) {
            guard let url = URL(string: urlString) else {
                return nil
            }
            self.init(url)
        }

        @discardableResult open func setCache(_ cache: NetRequest.NetCachePolicy?) -> Self {
            self.cache = cache
            return self
        }

        @discardableResult open func setTimeout(_ timeout: TimeInterval?) -> Self {
            self.timeout = timeout
            return self
        }

        @discardableResult open func setMainDocumentURL(_ mainDocumentURL: URL?) -> Self {
            self.mainDocumentURL = mainDocumentURL
            return self
        }

        @discardableResult open func setServiceType(_ serviceType: NetRequest.NetServiceType?) -> Self {
            self.serviceType = serviceType
            return self
        }

        @discardableResult open func setContentType(_ contentType: NetContentType?) -> Self {
            self.contentType = contentType
            return self
        }

        @discardableResult open func setContentLength(_ contentLength: NetContentLength?) -> Self {
            self.contentLength = contentLength
            return self
        }

        @discardableResult open func setAccept(_ accept: NetContentType?) -> Self {
            self.accept = accept
            return self
        }

        @discardableResult open func setAcceptEncodings(_ acceptEncodings: [NetContentEncoding]?) -> Self {
            self.acceptEncoding = acceptEncodings
            return self
        }

        @discardableResult open func addAcceptEncoding(_ acceptEncoding: NetContentEncoding?) -> Self {
            if self.acceptEncoding == nil {
                setAcceptEncodings([])
            }
            if let acceptEncoding = acceptEncoding, var acceptEncodings = self.acceptEncoding {
                if acceptEncodings.contains(acceptEncoding), let index = acceptEncodings.index(of: acceptEncoding) {
                    acceptEncodings.remove(at: index)
                }
                acceptEncodings.append(acceptEncoding)
                setAcceptEncodings(acceptEncodings)
            }
            return self
        }

        @discardableResult open func setCacheControls(_ cacheControls: [NetCacheControl]?) -> Self {
            self.cacheControl = cacheControls
            return self
        }

        @discardableResult open func addCacheControl(_ cacheControl: NetCacheControl?) -> Self {
            if self.cacheControl == nil {
                setCacheControls([])
            }
            if let cacheControl = cacheControl, var cacheControls = self.cacheControl {
                if cacheControls.contains(cacheControl), let index = cacheControls.index(of: cacheControl) {
                    cacheControls.remove(at: index)
                }
                cacheControls.append(cacheControl)
                setCacheControls(cacheControls)
            }
            return self
        }

        @discardableResult open func setAllowsCellularAccess(_ allowsCellularAccess: Bool?) -> Self {
            self.allowsCellularAccess = allowsCellularAccess
            return self
        }

        @discardableResult open func setMethod(_ method: NetRequest.NetMethod?) -> Self {
            self.method = method
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

        @discardableResult open func setBody(_ body: Data?) -> Self {
            if body != nil {
                setBodyStream(nil)
                if contentType == nil {
                    setContentType(.bin)
                }
                if method == nil {
                    setMethod(.POST)
                }
                if contentLength == nil, let length = body?.count {
                    setContentLength(NetContentLength(length))
                }
            }
            self.body = body
            return self
        }

        @discardableResult open func setURLParameters(_ urlParameters: [String: Any]?, resolvingAgainstBaseURL: Bool = false) -> Self {
            if var components = URLComponents(url: url, resolvingAgainstBaseURL: resolvingAgainstBaseURL) {
                components.percentEncodedQuery = nil
                if let urlParameters = urlParameters, urlParameters.count > 0 {
                    components.percentEncodedQuery = query(urlParameters)
                }
                if let url = components.url {
                    self.url = url
                }
            }
            return self
        }

        @discardableResult open func addURLParameter(_ key: String, value: Any?, resolvingAgainstBaseURL: Bool = false) -> Self {
            guard let value = value else {
                return self
            }
            if var components = URLComponents(url: url, resolvingAgainstBaseURL: resolvingAgainstBaseURL) {
                let percentEncodedQuery = (components.percentEncodedQuery.map { $0 + "&" } ?? "") + query([key: value])
                components.percentEncodedQuery = percentEncodedQuery
                if let url = components.url {
                    self.url = url
                }
            }
            return self
        }

        @discardableResult open func setFormParameters(_ formParameters: [String: Any]?, encoding: String.Encoding = .utf8, allowLossyConversion: Bool = false) -> Self {
            guard let formParameters = formParameters else {
                return self
            }
            body = query(formParameters).data(using: encoding, allowLossyConversion: allowLossyConversion)
            if contentType == nil {
                setContentType(.formURL)
            }
            if method == nil {
                setMethod(.POST)
            }
            if contentLength == nil, let length = body?.count {
                setContentLength(NetContentLength(length))
            }
            return self
        }

        @discardableResult open func setStringBody(_ stringBody: String?, encoding: String.Encoding = .utf8, allowLossyConversion: Bool = false) -> Self {
            guard let stringBody = stringBody else {
                return self
            }
            body = stringBody.data(using: encoding, allowLossyConversion: allowLossyConversion)
            if contentType == nil {
                setContentType(.txt)
            }
            if method == nil {
                setMethod(.POST)
            }
            if contentLength == nil, let length = body?.count {
                setContentLength(NetContentLength(length))
            }
            return self
        }

        @discardableResult open func setJSONObject<T: Encodable>(_ jsonObject: T?) throws -> Self {
            guard let jsonObject = jsonObject else {
                return self
            }
            body = try JSONEncoder().encode(jsonObject)
            if contentType == nil {
                setContentType(.json)
            }
            if method == nil {
                setMethod(.POST)
            }
            if contentLength == nil, let length = body?.count {
                setContentLength(NetContentLength(length))
            }
            return self
        }

        @discardableResult open func setJSONBody(_ jsonBody: Any?, options: JSONSerialization.WritingOptions = .prettyPrinted) throws -> Self {
            guard let jsonBody = jsonBody else {
                return self
            }
            body = try JSONSerialization.data(withJSONObject: jsonBody, options: options)
            if contentType == nil {
                setContentType(.json)
            }
            if method == nil {
                setMethod(.POST)
            }
            if contentLength == nil, let length = body?.count {
                setContentLength(NetContentLength(length))
            }
            return self
        }

        @discardableResult open func setPlistObject<T: Encodable>(_ plistObject: T?) throws -> Self {
            guard let plistObject = plistObject else {
                return self
            }
            body = try PropertyListEncoder().encode(plistObject)
            if contentType == nil {
                setContentType(.plist)
            }
            if method == nil {
                setMethod(.POST)
            }
            if contentLength == nil, let length = body?.count {
                setContentLength(NetContentLength(length))
            }
            return self
        }

        @discardableResult open func setPlistBody(_ plistBody: Any?, format: PropertyListSerialization.PropertyListFormat = .xml, options: PropertyListSerialization.WriteOptions = 0) throws -> Self {
            guard let plistBody = plistBody else {
                return self
            }
            body = try PropertyListSerialization.data(fromPropertyList: plistBody, format: format, options: options)
            if contentType == nil {
                setContentType(.plist)
            }
            if method == nil {
                setMethod(.POST)
            }
            if contentLength == nil, let length = body?.count {
                setContentLength(NetContentLength(length))
            }
            return self
        }

        @discardableResult open func setBodyStream(_ bodyStream: InputStream?) -> Self {
            if bodyStream != nil {
                setBody(nil)
                if contentType == nil {
                    setContentType(.bin)
                }
                if method == nil {
                    setMethod(.POST)
                }
            }
            self.bodyStream = bodyStream
            return self
        }

        @discardableResult open func setMultipartFormData(_ multipartFormData: NetMultipartFormData?) throws -> Self {
            guard let multipartFormData = multipartFormData else {
                return self
            }
            body = try multipartFormData.encode()
            setContentType(.custom(multipartFormData.contentType))
            setContentLength(multipartFormData.contentLength)
            if method == nil {
                setMethod(.POST)
            }
            return self
        }

        @discardableResult open func setHandleCookies(_ handleCookies: Bool?) -> Self {
            self.handleCookies = handleCookies
            return self
        }

        @discardableResult open func setUsePipelining(_ usePipelining: Bool?) -> Self {
            self.usePipelining = usePipelining
            return self
        }

        @discardableResult open func setBasicAuthorization(user: String, password: String) -> Self {
            self.authorization = .basic(user: user, password: password)
            return self
        }

        @discardableResult open func setBearerAuthorization(token: String) -> Self {
            self.authorization = .bearer(token: token)
            return self
        }

        @discardableResult open func setCustomAuthorization(_ authorization: String) -> Self {
            self.authorization = .custom(authorization)
            return self
        }

        public func build() -> NetRequest {
            return NetRequest(self)
        }

    }

    public func builder() -> Builder {
        return NetRequest.builder(self)
    }

    public static func builder(_ netRequest: NetRequest) -> Builder {
        return Builder(netRequest)
    }

    public static func builder(_ urlRequest: URLRequest) -> Builder? {
        return Builder(urlRequest)
    }

    public static func builder(_ url: URL) -> Builder {
        return Builder(url)
    }

    public static func builder(_ urlString: String) -> Builder? {
        return Builder(urlString)
    }

    public init(_ builder: Builder) {
        self.init(builder.url, cache: builder.cache ?? .useProtocolCachePolicy, timeout: builder.timeout ?? 60, mainDocumentURL: builder.mainDocumentURL, serviceType: builder.serviceType ?? .default, contentType: builder.contentType, contentLength: builder.contentLength, accept: builder.accept, acceptEncoding: builder.acceptEncoding, cacheControl: builder.cacheControl, allowsCellularAccess: builder.allowsCellularAccess ?? true, method: builder.method ?? .GET, headers: builder.headers, body: builder.body, bodyStream: builder.bodyStream, handleCookies: builder.handleCookies ?? true, usePipelining: builder.usePipelining ?? true, authorization: builder.authorization ?? .none)
    }

}

extension NetRequest.Builder {

    fileprivate func query(_ parameters: [String: Any]) -> String {
        var components = [(String, String)]()

        for key in parameters.keys.sorted(by: <) {
            if let value = parameters[key] {
                components += queryComponents(key, value: value)
            }
        }

        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }

    fileprivate func queryComponents(_ key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []

        if let dictionary = value as? [String: Any] {
            for (dictionaryKey, value) in dictionary {
                components += queryComponents("\(key)[\(dictionaryKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents("\(key)[]", value: value)
            }
        } else if let value = value as? NSNumber {
            if CFBooleanGetTypeID() == CFGetTypeID(value) {
                components.append((escape(key), escape((value.boolValue ? "1" : "0"))))
            } else {
                components.append((escape(key), escape("\(value)")))
            }
        } else if let bool = value as? Bool {
            components.append((escape(key), escape((bool ? "1" : "0"))))
        } else {
            components.append((escape(key), escape("\(value)")))
        }

        return components
    }

    fileprivate func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
    }

}
