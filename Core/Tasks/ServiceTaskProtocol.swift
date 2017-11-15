//  ServiceTaskProtocol.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import Foundation

public enum ServiceTaskError: Error {
    case netError(message: String, underlying: Error?),
    serverError(message: String, underlying: Error?),
    unauthorizedError(message: String, underlying: Error?),
    parserError(message: String, underlying: Error?)

    public var localizedDescription: String {
        switch self {
        case .netError(let message, let underlying), .serverError(let message, let underlying), .parserError(let message, let underlying), .unauthorizedError(let message, let underlying):
            if let localizedDescription = underlying?.localizedDescription {
                return message + " " + localizedDescription
            }
            return message
        }
    }
}

public protocol ServiceTaskProtocol: TaskProtocol {}
