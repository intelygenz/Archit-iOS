//  NetworkServiceProtocol.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import Foundation

public enum NetworkServiceError: Error {
    case serviceError(message: String, underlying: ServiceTaskError)

    public var localizedDescription: String {
        switch self {
        case .serviceError(_, let underlying):
            return underlying.localizedDescription
        }
    }
}

public protocol NetworkServiceProtocol: ServiceProtocol {
    func cancel(_ tasks: [TaskProtocol])
}

public extension NetworkServiceProtocol {
    func cancel(_ tasks: [TaskProtocol]) {
        tasks.forEach { task in
            task.cancel()
        }
    }
}
