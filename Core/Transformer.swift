//  Transformer.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import Foundation

public protocol Transformer {
    associatedtype Source: Codable
    associatedtype Result
    func transform(source: Source) throws -> Result
    func transform(source: [Source]) throws -> [Result]
    func transform(result: Result) throws -> Source
    func transform(result: [Result]) throws -> [Source]
}

public extension Transformer {

    func transform(source: Source) throws -> Result {
        throw ServiceTaskError.parserError(message: "You must define your Transformer implementation.", underlying: nil)
    }

    func transform(source: [Source]) throws -> [Result] {
        return try source.flatMap({ return try transform(source: $0) })
    }

    func transform(result: Result) throws -> Source {
        throw ServiceTaskError.parserError(message: "You must define your Transformer implementation.", underlying: nil)
    }

    func transform(result: [Result]) throws -> [Source] {
        return try result.flatMap({ return try transform(result: $0) })
    }

}
