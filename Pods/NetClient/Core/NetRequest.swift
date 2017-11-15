//
//  NetRequest.swift
//  Net
//
//  Created by Alex Rupérez on 23/3/17.
//
//

import Foundation

public struct NetRequest {

    public typealias NetContentLength = UInt64

    public enum NetCachePolicy: UInt {
        case useProtocolCachePolicy = 0, reloadIgnoringLocalCacheData = 1, returnCacheDataElseLoad = 2, returnCacheDataDontLoad = 3
    }

    public enum NetServiceType: UInt {
        case `default`, voip, video, background, voice, callSignaling = 11
    }

    public enum NetMethod: String {
        case GET, POST, PUT, DELETE, PATCH, UPDATE, HEAD, TRACE, OPTIONS, CONNECT, SEARCH, COPY, MERGE, LABEL, LOCK, UNLOCK, MOVE, MKCOL, PROPFIND, PROPPATCH
    }

    public enum NetContentEncoding: String {
        case gzip, compress, deflate, identity, br
    }

    public let url: URL

    public let cache: NetCachePolicy

    public let timeout: TimeInterval

    public let mainDocumentURL: URL?

    public let serviceType: NetServiceType

    public let contentType: NetContentType?

    public let contentLength: NetContentLength?

    public let accept: NetContentType?

    public let acceptEncoding: [NetContentEncoding]?

    public let cacheControl: [NetCacheControl]?

    public let allowsCellularAccess: Bool

    public let httpMethod: NetMethod

    public let headers: [String : String]?

    public let body: Data?

    public let bodyStream: InputStream?

    public let handleCookies: Bool

    public let usePipelining: Bool

    public let authorization: NetAuthorization

}

extension NetRequest {

    public init(_ url: URL, cache: NetCachePolicy = .useProtocolCachePolicy, timeout: TimeInterval = 60, mainDocumentURL: URL? = nil, serviceType: NetServiceType = .default, contentType: NetContentType? = nil, contentLength: NetContentLength? = nil, accept: NetContentType? = nil, acceptEncoding: [NetContentEncoding]? = nil, cacheControl: [NetCacheControl]? = nil, allowsCellularAccess: Bool = true, method: NetMethod = .GET, headers: [String : String]? = nil, body: Data? = nil, bodyStream: InputStream? = nil, handleCookies: Bool = true, usePipelining: Bool = true, authorization: NetAuthorization = .none) {
        self.url = url
        self.cache = cache
        self.timeout = timeout
        self.mainDocumentURL = mainDocumentURL
        self.serviceType = serviceType
        self.contentType = contentType
        self.contentLength = contentLength
        self.accept = accept
        self.acceptEncoding = acceptEncoding
        self.cacheControl = cacheControl
        self.allowsCellularAccess = allowsCellularAccess
        self.httpMethod = method
        self.headers = headers
        self.body = body
        self.bodyStream = bodyStream
        self.handleCookies = handleCookies
        self.usePipelining = usePipelining
        self.authorization = authorization
    }
    
}

extension NetRequest {

    public init?(_ urlString: String, cache: NetCachePolicy = .useProtocolCachePolicy, timeout: TimeInterval = 60, mainDocumentURL: URL? = nil, serviceType: NetServiceType = .default, contentType: NetContentType? = nil, contentLength: NetContentLength? = nil, accept: NetContentType? = nil, acceptEncoding: [NetContentEncoding]? = nil, cacheControl: [NetCacheControl]? = nil, allowsCellularAccess: Bool = true, method: NetMethod = .GET, headers: [String : String]? = nil, body: Data? = nil, bodyStream: InputStream? = nil, handleCookies: Bool = true, usePipelining: Bool = true, authorization: NetAuthorization = .none) {
        guard let url = URL(string: urlString) else {
            return nil
        }
        self.init(url, cache: cache, timeout: timeout, mainDocumentURL: mainDocumentURL, serviceType: serviceType, contentType: contentType, contentLength: contentLength, accept: accept, acceptEncoding: acceptEncoding, cacheControl: cacheControl, allowsCellularAccess: allowsCellularAccess, method: method, headers: headers, body: body, bodyStream: bodyStream, handleCookies: handleCookies, usePipelining: usePipelining, authorization: authorization)
    }

}

extension NetRequest: CustomStringConvertible {

    public var description: String {
        return httpMethod.rawValue + " " + url.absoluteString
    }

}

extension NetRequest: CustomDebugStringConvertible {

    public var debugDescription: String {
        var components = ["$ curl -i"]

        if httpMethod != .GET {
            components.append("-X \(httpMethod.rawValue)")
        }

        if let headers = headers {
            for (field, value) in headers where field != "Content-Type" && field != "Accept" && field != "Accept-Encoding" && field != "Cache-Control" && field != "Content-Length" {
                components.append("-H \"\(field): \(value)\"")
            }
        }

        if let contentType = contentType {
            components.append("-H \"Content-Type: \(contentType.rawValue)\"")
        }

        if let contentLength = contentLength {
            components.append("-H \"Content-Length: \(contentLength)\"")
        }

        if let accept = accept {
            components.append("-H \"Accept: \(accept.rawValue)\"")
        }

        if let acceptEncoding = acceptEncoding {
            components.append("-H \"Accept-Encoding: \(acceptEncoding.flatMap({$0.rawValue}).joined(separator: ", "))\"")
        }

        if let cacheControl = cacheControl {
            components.append("-H \"Cache-Control: \(cacheControl.flatMap({$0.rawValue}).joined(separator: ", "))\"")
        }

        if authorization != .none {
            components.append("-H \"Authorization: \(authorization.rawValue)\"")
        }

        if let body = body, let bodyString = String(data: body, encoding: .utf8) {
            var escapedBody = bodyString.replacingOccurrences(of: "\\\"", with: "\\\\\"")
            escapedBody = escapedBody.replacingOccurrences(of: "\"", with: "\\\"")

            components.append("-d \"\(escapedBody)\"")
        }

        components.append("\"\(url.absoluteString)\"")

        return components.joined(separator: " \\\n\t")
    }

}

extension NetRequest: Hashable {

    public var hashValue: Int {
        return url.hashValue + httpMethod.hashValue
    }

}

extension NetRequest: Equatable {

    public static func ==(lhs: NetRequest, rhs: NetRequest) -> Bool {
        return lhs.url == rhs.url && lhs.httpMethod == rhs.httpMethod
    }

}
