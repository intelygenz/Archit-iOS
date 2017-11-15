//
//  Kommander.swift
//  Kommander
//
//  Created by Alejandro Ruperez Hernando on 26/1/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import Foundation

/// Kommander manager
open class Kommander {

    /// Deliverer
    final let deliverer: Dispatcher
    /// Executor
    final let executor: Dispatcher

    /// Kommander instance with CurrentDispatcher deliverer and MainDispatcher executor
    open static var main: Kommander { return Kommander(executor: .main) }
    /// Kommander instance with CurrentDispatcher deliverer and CurrentDispatcher executor
    open static var current: Kommander { return Kommander(executor: .current) }
    /// Kommander instance with CurrentDispatcher deliverer and Dispatcher executor with default quality of service
    open static var `default`: Kommander { return Kommander() }
    /// Kommander instance with CurrentDispatcher deliverer and Dispatcher executor with user interactive quality of service
    open static var userInteractive: Kommander { return Kommander(executor: .userInteractive) }
    /// Kommander instance with CurrentDispatcher deliverer and Dispatcher executor with user initiated quality of service
    open static var userInitiated: Kommander { return Kommander(executor: .userInitiated) }
    /// Kommander instance with CurrentDispatcher deliverer and Dispatcher executor with utility quality of service
    open static var utility: Kommander { return Kommander(executor: .utility) }
    /// Kommander instance with CurrentDispatcher deliverer and Dispatcher executor with background quality of service
    open static var background: Kommander { return Kommander(executor: .background) }

    /// Kommander instance with deliverer and executor
    public init(deliverer: Dispatcher = .current, executor: Dispatcher = .default) {
        self.deliverer = deliverer
        self.executor = executor
    }

    /// Kommander instance with deliverer and custom OperationQueue executor
    public init(deliverer: Dispatcher = .current, name: String = UUID().uuidString, qos: QualityOfService = .default, maxConcurrentOperationCount: Int = OperationQueue.defaultMaxConcurrentOperationCount) {
        self.deliverer = deliverer
        executor = Dispatcher(name: name, qos: qos, maxConcurrentOperationCount: maxConcurrentOperationCount)
    }

    /// Build Kommand<Result> instance with an actionBlock returning generic and throwing errors
    open func makeKommand<Result>(_ actionBlock: @escaping () throws -> Result) -> Kommand<Result> {
        return Kommand<Result>(deliverer: deliverer, executor: executor, actionBlock: actionBlock)
    }

    /// Build [Kommand<Result>] instances collection with actionBlocks returning generic and throwing errors
    open func makeKommands<Result>(_ actionBlocks: [() throws -> Result]) -> [Kommand<Result>] {
        var kommands = [Kommand<Result>]()
        for actionBlock in actionBlocks {
            kommands.append(Kommand<Result>(deliverer: deliverer, executor: executor, actionBlock: actionBlock))
        }
        return kommands
    }

    /// Execute [Kommand<Result>] instances collection concurrently or sequentially after delay
    open func execute<Result>(_ kommands: [Kommand<Result>], concurrent: Bool = true, waitUntilFinished: Bool = false, after delay: DispatchTimeInterval) {
        executor.execute(after: delay) { 
            self.execute(kommands, concurrent: concurrent, waitUntilFinished: waitUntilFinished)
        }
    }

    /// Execute [Kommand<Result>] instances collection concurrently or sequentially
    open func execute<Result>(_ kommands: [Kommand<Result>], concurrent: Bool = true, waitUntilFinished: Bool = false) {
        let executionBlocks = kommands.map { kommand in
            executionBlock(kommand)
        }
        let operations = executor.execute(executionBlocks, concurrent: concurrent, waitUntilFinished: waitUntilFinished)
        for (index, kommand) in kommands.enumerated() {
            kommand.operation = operations[index]
        }
    }

    /// Cancel [Kommand<Result>] instances collection after delay
    open func cancel<Result>(_ kommands: [Kommand<Result>], throwingError: Bool = false, after delay: DispatchTimeInterval) {
        executor.execute(after: delay) {
            self.cancel(kommands, throwingError: throwingError)
        }
    }

    /// Cancel [Kommand<Result>] instances collection
    open func cancel<Result>(_ kommands: [Kommand<Result>], throwingError: Bool = false) {
        for kommand in kommands {
            kommand.cancel(throwingError)
        }
    }

    /// Retry [Kommand<Result>] instances collection after delay
    open func retry<Result>(_ kommands: [Kommand<Result>], after delay: DispatchTimeInterval) {
        executor.execute(after: delay) {
            self.retry(kommands)
        }
    }

    /// Retry [Kommand<Result>] instances collection
    open func retry<Result>(_ kommands: [Kommand<Result>]) {
        for kommand in kommands {
            kommand.retry()
        }
    }

}

private extension Kommander {

    final func executionBlock<Result>(_ kommand: Kommand<Result>) -> () -> Void {
        return {
            guard kommand.state == .ready else {
                return
            }
            do {
                if let actionBlock = kommand.actionBlock {
                    kommand.state = .running
                    let result = try actionBlock()
                    guard kommand.state == .running else {
                        return
                    }
                    self.deliverer.execute {
                        kommand.state = .finished
                        kommand.successBlock?(result)
                    }
                }
            } catch {
                guard kommand.state == .running else {
                    return
                }
                self.deliverer.execute {
                    kommand.state = .finished
                    kommand.errorBlock?(error)
                }
            }
        }
    }

}
