//
//  Kommand.swift
//  Kommander
//
//  Created by Alejandro Ruperez Hernando on 26/1/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import Foundation

/// Kommand<Result> state
public enum State {
    /// Uninitialized state
    case uninitialized
    /// Ready state
    case ready
    /// Executing state
    case running
    /// Finished state
    case finished
    /// Cancelled state
    case cancelled
}

/// Generic Kommand
open class Kommand<Result> {

    /// Action block type
    public typealias ActionBlock = () throws -> Result
    /// Success block type
    public typealias SuccessBlock = (_ result: Result) -> Void
    /// Error block type
    public typealias ErrorBlock = (_ error: Error?) -> Void

    /// Kommand<Result> state
    internal(set) public final var state = State.uninitialized

    /// Deliverer
    private final weak var deliverer: Dispatcher?
    /// Executor
    private final weak var executor: Dispatcher?
    /// Action block
    private(set) final var actionBlock: ActionBlock?
    /// Success block
    private(set) final var successBlock: SuccessBlock?
    /// Error block
    private(set) final var errorBlock: ErrorBlock?
    /// Operation to cancel
    internal(set) final weak var operation: Operation?

    /// Kommand<Result> instance with deliverer, executor and actionBlock returning generic and throwing errors
    public init(deliverer: Dispatcher = .current, executor: Dispatcher = .default, actionBlock: @escaping ActionBlock) {
        self.deliverer = deliverer
        self.executor = executor
        self.actionBlock = actionBlock
        state = .ready
    }

    /// Release all resources
    deinit {
        operation = nil
        deliverer = nil
        executor = nil
        actionBlock = nil
        successBlock = nil
        errorBlock = nil
    }

    /// Specify Kommand<Result> success block
    @discardableResult open func onSuccess(_ onSuccess: @escaping SuccessBlock) -> Self {
        self.successBlock = onSuccess
        return self
    }

    /// Specify Kommand<Result> error block
    @discardableResult open func onError(_ onError: @escaping ErrorBlock) -> Self {
        self.errorBlock = onError
        return self
    }

    /// Execute Kommand<Result> after delay
    @discardableResult open func execute(after delay: DispatchTimeInterval) -> Self {
        executor?.execute(after: delay, block: { 
            self.execute()
        })
        return self
    }

    /// Execute Kommand<Result>
    @discardableResult open func execute() -> Self {
        guard state == .ready else {
            return self
        }
        operation = executor?.execute {
            do {
                if let actionBlock = self.actionBlock {
                    self.state = .running
                    let result = try actionBlock()
                    guard self.state == .running else {
                        return
                    }
                    self.deliverer?.execute {
                        self.state = .finished
                        self.successBlock?(result)
                    }
                }
            } catch {
                guard self.state == .running else {
                    return
                }
                self.deliverer?.execute {
                    self.state = .finished
                    self.errorBlock?(error)
                }
            }
        }
        return self
    }

    /// Cancel Kommand<Result> after delay
    @discardableResult open func cancel(_ throwingError: Bool = false, after delay: DispatchTimeInterval) -> Self {
        executor?.execute(after: delay, block: {
            self.cancel(throwingError)
        })
        return self
    }

    /// Cancel Kommand<Result>
    @discardableResult open func cancel(_ throwingError: Bool = false) -> Self {
        guard state != .cancelled else {
            return self
        }
        self.deliverer?.execute {
            if throwingError {
                self.errorBlock?(KommandCancelledError(self))
            }
        }
        if let operation = operation, !operation.isFinished {
            operation.cancel()
        }
        state = .cancelled
        return self
    }

    /// Retry Kommand<Result> after delay
    @discardableResult open func retry(after delay: DispatchTimeInterval) -> Self {
        executor?.execute(after: delay, block: {
            self.retry()
        })
        return self
    }

    /// Retry Kommand<Result>
    @discardableResult open func retry() -> Self {
        guard state == .cancelled else {
            return self
        }
        state = .ready
        return execute()
    }

}
