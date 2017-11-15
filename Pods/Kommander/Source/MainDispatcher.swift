//
//  MainDispatcher.swift
//  Kommander
//
//  Created by Alejandro Ruperez Hernando on 30/1/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import Foundation

/// Main queue dispatcher
open class MainDispatcher: Dispatcher {

    /// Dispatcher instance with main OperationQueue
    public init() {
        super.init()
        operationQueue = OperationQueue.main
        dispatchQueue = DispatchQueue.main
    }

}
