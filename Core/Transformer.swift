//  Transformer.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import Foundation

public protocol Transformer {
    associatedtype Source
    associatedtype Result
    func transform(source: Source) -> Result?
    func transform(source: [Source]) -> [Result]
    func transform(result: Result) -> Source?
    func transform(result: [Result]) -> [Source]
}

public extension Transformer {
    func transform(source: [Source]) -> [Result] {
        return source.flatMap({ return transform(source: $0) })
    }

    func transform(result: [Result]) -> [Source] {
        return result.flatMap({ return transform(result: $0) })
    }
}
