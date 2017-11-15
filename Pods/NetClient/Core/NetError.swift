//
//  NetError.swift
//  Net
//
//  Created by Alex Rupérez on 22/3/17.
//
//

import Foundation

public enum NetError: Error {
    case net(code: Int?, message: String, headers: [AnyHashable : Any]?, object: Any?, underlying: Error?),
    parse(code: Int?, message: String, object: Any?, underlying: Error?)
}

extension NetError {

    public func object<T>() throws -> T {
        switch self {
        case .net(let code, _, _, let object, let underlying):
            return try objectTransformation(code, object, underlying)
        case .parse(let code, _, let object, let underlying):
            return try objectTransformation(code, object, underlying)
        }
    }

    public func decode<T: Decodable>() throws -> T {
        switch self {
        case .net(let code, _, _, let object, let underlying):
            return try decodeTransformation(code, object, underlying)
        case .parse(let code, _, let object, let underlying):
            return try decodeTransformation(code, object, underlying)
        }
    }

    private func objectTransformation<T>(_ code: Int? = nil, _ object: Any? = nil, _ underlying: Error? = nil) throws -> T {
        do {
            return try NetTransformer.object(object: object)
        } catch {
            throw handle(error, code, underlying)
        }
    }

    private func decodeTransformation<T: Decodable>(_ code: Int? = nil, _ object: Any? = nil, _ underlying: Error? = nil) throws -> T {
        do {
            return try NetTransformer.decode(object: object)
        } catch {
            throw handle(error, code, underlying)
        }
    }

    private func handle(_ error: Error, _ code: Int? = nil, _ underlying: Error? = nil) -> Error {
        switch error as! NetError {
        case .parse(let transformCode, let message, let object, let transformUnderlying):
            return NetError.parse(code: transformCode ?? code, message: message, object: object, underlying: transformUnderlying ?? underlying)
        default:
            return error
        }
    }
    
}

extension NetError {

    public var localizedDescription: String {
        switch self {
        case .net(_, let message, _, _, let underlying), .parse(_, let message, _, let underlying):
            if let localizedDescription = underlying?.localizedDescription, localizedDescription != message {
                return message + " " + localizedDescription
            }
            return message
        }
    }

}

extension NetError: CustomStringConvertible {

    public var description: String {
        return localizedDescription
    }

}

extension NetError: CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {
        case .net(let code, _, _, _, _), .parse(let code, _, _, _):
            if let code = code?.description {
                return code + " " + localizedDescription
            }
            return localizedDescription
        }
    }
    
}

extension NetError: CustomNSError {

    public var errorCode: Int {
        switch self {
        case .net(let code, _, _, _, _):
            return code ?? 0
        case .parse(let code, _, _, _):
            return code ?? 1
        }
    }

    public var errorUserInfo: [String : Any] {
        switch self {
        case .net(_, let message, _, _, let underlying), .parse(_, let message, _, let underlying):
            guard let underlying = underlying else {
                return [NSLocalizedDescriptionKey: localizedDescription, NSLocalizedFailureReasonErrorKey: message]
            }
            return [NSLocalizedDescriptionKey: localizedDescription, NSLocalizedFailureReasonErrorKey: message, NSUnderlyingErrorKey: underlying]
        }
    }

}
