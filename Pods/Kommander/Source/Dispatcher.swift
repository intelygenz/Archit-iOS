//
//  Dispatcher.swift
//  Kommander
//
//  Created by Alejandro Ruperez Hernando on 26/1/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import Foundation

/// Dispatcher
open class Dispatcher {

    /// Dispatcher operation queue
    final var operationQueue = OperationQueue()
    /// Dispatcher dispatch queue
    final var dispatchQueue = DispatchQueue(label: UUID().uuidString)

    /// Main queue dispatcher
    open static var main: Dispatcher { return MainDispatcher() }
    /// Current queue dispatcher
    open static var current: Dispatcher { return CurrentDispatcher() }
    /// Dispatcher with default quality of service
    open static var `default`: Dispatcher { return Dispatcher() }
    /// Dispatcher with user interactive quality of service
    open static var userInteractive: Dispatcher { return Dispatcher(qos: .userInteractive) }
    /// Dispatcher with user initiated quality of service
    open static var userInitiated: Dispatcher { return Dispatcher(qos: .userInitiated) }
    /// Dispatcher with utility quality of service
    open static var utility: Dispatcher { return Dispatcher(qos: .utility) }
    /// Dispatcher with background quality of service
    open static var background: Dispatcher { return Dispatcher(qos: .background) }

    /// Dispatcher instance with custom OperationQueue
    public init(name: String = UUID().uuidString, qos: QualityOfService = .default, maxConcurrentOperationCount: Int = OperationQueue.defaultMaxConcurrentOperationCount) {
        operationQueue.name = name
        operationQueue.qualityOfService = qos
        operationQueue.maxConcurrentOperationCount = maxConcurrentOperationCount
        dispatchQueue = DispatchQueue(label: name, qos: dispatchQoS(qos), attributes: .concurrent, autoreleaseFrequency: .inherit, target: operationQueue.underlyingQueue)
    }

    /// Execute Operation instance in OperationQueue
    open func execute(_ operation: Operation) {
        operationQueue.addOperation(operation)
    }

    /// Execute [Operation] instance collection in OperationQueue
    open func execute(_ operations: [Operation], waitUntilFinished: Bool = false) {
        operationQueue.addOperations(operations, waitUntilFinished: waitUntilFinished)
    }

    /// Execute block in priority queue
    @discardableResult open func execute(_ block: @escaping () -> Void) -> Operation {
        let blockOperation = BlockOperation(block: block)
        execute(blockOperation)
        return blockOperation
    }

    /// Execute [block] collection in priority queue (if possible) concurrently or sequentially
    @discardableResult open func execute(_ blocks: [() -> Void], concurrent: Bool = true, waitUntilFinished: Bool = false) -> [Operation] {
        var lastOperation: Operation?
        let operations = blocks.map { block -> Operation in
            let blockOperation = BlockOperation(block: block)
            if let lastOperation = lastOperation, !concurrent {
                blockOperation.addDependency(lastOperation)
            }
            lastOperation = blockOperation
            return blockOperation
        }
        execute(operations, waitUntilFinished: waitUntilFinished)
        return operations
    }

    /// Execute block in DispatchQueue after delay
    open func execute(after delay: DispatchTimeInterval, block: @escaping () -> Void) {
        guard delay != .never else {
            return
        }
        dispatchQueue.asyncAfter(deadline: .now() + delay, execute: block)
    }

    /// Execute DispatchWorkItem instance in DispatchQueue after delay
    open func execute(after delay: DispatchTimeInterval, work: DispatchWorkItem) {
        guard delay != .never else {
            work.cancel()
            return
        }
        dispatchQueue.asyncAfter(deadline: .now() + delay, execute: work)
    }

    /// Execute DispatchWorkItem instance in DispatchQueue
    open func execute(_ work: DispatchWorkItem) {
        dispatchQueue.async(execute: work)
    }

}

private extension Dispatcher {

    final func dispatchQoS(_ qos: QualityOfService) -> DispatchQoS {
        switch qos {
        case .userInteractive: return .userInteractive
        case .userInitiated: return .userInitiated
        case .utility: return .utility
        case .background: return .background
        default: return .default
        }
    }

}
