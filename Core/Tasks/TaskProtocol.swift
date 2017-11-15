//  TaskProtocol.swift
//  Created by Alex Rupérez on 7/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import Foundation

public protocol TaskProtocol {
    @discardableResult func execute() throws -> Any?
    func cancel()
}
