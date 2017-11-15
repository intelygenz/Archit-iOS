//
//  NetResponse.swift
//  Net
//
//  Created by Alex Rupérez on 22/3/17.
//
//

import Foundation

public struct NetResponse {

    public let url: URL?

    public let mimeType: String?

    public let contentLength: Int64?

    public let textEncoding: String?

    public let filename: String?

    public let statusCode: Int?

    public let headers: [AnyHashable : Any]?

    public let localizedDescription: String?

    public let userInfo: [AnyHashable : Any]?

    public fileprivate(set) weak var netTask: NetTask?

    let responseObject: Any?

}

extension NetResponse {

    public init(_ url: URL? = nil, mimeType: String? = nil, contentLength: Int64 = -1, textEncoding: String? = nil, filename: String? = nil, statusCode: Int? = nil, headers: [AnyHashable : Any]? = nil, localizedDescription: String? = nil, userInfo: [AnyHashable : Any]? = nil, netTask: NetTask?, responseObject: Any? = nil) {
        self.url = url
        self.mimeType = mimeType
        self.contentLength = contentLength != -1 ? contentLength : nil
        self.textEncoding = textEncoding
        self.filename = filename
        self.statusCode = statusCode
        self.headers = headers
        self.localizedDescription = localizedDescription
        self.userInfo = userInfo
        self.netTask = netTask
        self.responseObject = responseObject
    }

}

extension NetResponse {

    public func object<T>() throws -> T {
        do {
            return try NetTransformer.object(object: responseObject)
        } catch {
            throw handle(error)
        }
    }

    public func decode<T: Decodable>() throws -> T {
        do {
            return try NetTransformer.decode(object: responseObject)
        } catch {
            throw handle(error)
        }
    }

    private func handle(_ error: Error) -> Error {
        switch error as! NetError {
        case .parse(let transformCode, let message, let object, let underlying):
            return NetError.parse(code: transformCode ?? statusCode, message: message, object: object ?? responseObject, underlying: underlying)
        default:
            return error
        }
    }

}

extension NetResponse: Equatable {

    public static func ==(lhs: NetResponse, rhs: NetResponse) -> Bool {
        guard lhs.url != nil && rhs.url != nil else {
            return false
        }
        return lhs.url == rhs.url
    }

}

extension NetResponse: CustomStringConvertible {

    public var description: String {
        var description = ""
        if let statusCode = statusCode?.description {
            description = description + statusCode
        }
        if let url = url?.description {
            if description.count > 0 {
                description = description + " "
            }
            description = description + url
        }
        if let localizedDescription = localizedDescription?.description {
            if description.count > 0 {
                description = description + " "
            }
            description = description + "(\(localizedDescription))"
        }
        return description
    }

}

extension NetResponse: CustomDebugStringConvertible {

    public var debugDescription: String {
        return description
    }
    
}
