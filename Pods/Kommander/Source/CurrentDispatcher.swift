//
//  CurrentDispatcher.swift
//  Kommander
//
//  Created by Alejandro Ruperez Hernando on 30/1/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import Foundation

/// Current queue dispatcher
open class CurrentDispatcher: MainDispatcher {

    /// Dispatcher instance with current OperationQueue
    public override init() {
        super.init()
        if let currentOperationQueue = OperationQueue.current {
            operationQueue = currentOperationQueue
            if let underlyingQueue = currentOperationQueue.underlyingQueue {
                dispatchQueue = underlyingQueue
            }
        }
    }

}
