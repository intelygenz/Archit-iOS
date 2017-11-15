//  NetworkServiceTransformer.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import Foundation

class NetworkServiceTransformer<Source: Codable, Result>: Transformer {
    func transform(source: Source) -> Result? {
        assertionFailure("You should use your own NetworkServiceTransformer subclass.")
        return nil
    }

    func transform(result: Result) -> Source? {
        assertionFailure("You should use your own NetworkServiceTransformer subclass.")
        return nil
    }
}
