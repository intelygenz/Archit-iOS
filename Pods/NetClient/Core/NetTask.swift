//
//  NetTask.swift
//  Net
//
//  Created by Alex Rupérez on 25/3/17.
//
//

import Foundation

public typealias NetTaskIdentifier = Int

public protocol NetTaskProtocol: class {

    @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
    var progress: Progress { get }

    @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
    var earliestBeginDate: Date? { get set }

    func cancel()

    func suspend()

    func resume()

}

open class NetTask {

    public enum NetState : Int {
        case running, suspended, canceling, completed, waitingForConnectivity
    }

    open let identifier: NetTaskIdentifier

    open internal(set) var request: NetRequest?

    open internal(set) var response: NetResponse? {
        didSet {
            state = .completed
        }
    }

    open let taskDescription: String?

    open internal(set) var state: NetState

    open internal(set) var error: NetError? {
        didSet {
            state = .completed
        }
    }

    open internal(set) var priority: Float?

    open internal(set) var progress: Progress

    open internal(set) var metrics: NetTaskMetrics?

    var netTask: NetTaskProtocol?

    open internal(set) var retryCount: UInt = 0

    fileprivate(set) var dispatchSemaphore: DispatchSemaphore?

    var completionClosure: CompletionClosure?

    fileprivate(set) var retryClosure: RetryClosure?

    var progressClosure: ProgressClosure?

    public init(_ identifier: NetTaskIdentifier? = nil, request: NetRequest? = nil , response: NetResponse? = nil, taskDescription: String? = nil, state: NetState = .suspended, error: NetError? = nil, priority: Float? = nil, progress: Progress? = nil, metrics: NetTaskMetrics? = nil, task: NetTaskProtocol? = nil) {
        self.request = request
        self.identifier = identifier ?? NetTaskIdentifier(arc4random())
        self.response = response
        self.taskDescription = taskDescription ?? request?.description
        self.state = state
        self.error = error
        self.priority = priority
        if let progress = progress {
            self.progress = progress
        } else if #available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *), let progress = task?.progress {
            self.progress = progress
        } else {
            self.progress = Progress(totalUnitCount: Int64(request?.contentLength ?? 0))
        }
        self.netTask = task
    }

    deinit {
        completionClosure = nil
        progressClosure = nil
        retryClosure = nil
    }

}

extension NetTask {

    public typealias CompletionClosure = (NetResponse?, NetError?) -> Swift.Void
    public typealias RetryClosure = (NetResponse?, NetError?, UInt) -> Bool

    @discardableResult open func async(_ completion: CompletionClosure? = nil) -> Self {
        guard state == .suspended else {
            return self
        }
        completionClosure = completion
        resume()
        return self
    }

    open func sync() throws -> NetResponse {
        guard state == .suspended else {
            if let response = response {
                return response
            } else if let error = error {
                throw error
            } else {
                throw NetError.net(code: error?._code, message: error?.localizedDescription ?? "", headers: response?.headers, object: response?.responseObject, underlying: error)
            }
        }
        dispatchSemaphore = DispatchSemaphore(value: 0)
        resume()
        let dispatchTimeoutResult = dispatchSemaphore?.wait(timeout: DispatchTime.distantFuture)
        if dispatchTimeoutResult == .timedOut {
            let urlError = URLError(.timedOut)
            error = NetError.net(code: urlError._code, message: urlError.localizedDescription, headers: response?.headers, object: response?.responseObject, underlying: urlError)
        }
        if let error = error {
            throw error
        }
        return response!
    }

    open func cached() throws -> NetResponse {
        if let response = response {
            return response
        }
        guard let urlRequest = request?.urlRequest else {
            guard let taskError = error else {
                let error = URLError(.resourceUnavailable)
                throw NetError.net(code: error._code, message: "Request not found.", headers: response?.headers, object: response?.responseObject, underlying: error)
            }
            throw taskError
        }
        if let cachedResponse = URLCache.shared.cachedResponse(for: urlRequest) {
            return NetResponse(cachedResponse, self)
        }
        guard let taskError = error else {
            let error = URLError(.resourceUnavailable)
            throw NetError.net(code: error._code, message: "Cached response not found.", headers: response?.headers, object: response?.responseObject, underlying: error)
        }
        throw taskError
    }

    @discardableResult open func retry(_ retry: @escaping RetryClosure) -> Self {
        retryClosure = retry
        return self
    }

}

extension NetTask {

    public typealias ProgressClosure = (Progress) -> Swift.Void

    @discardableResult open func progress(_ progressClosure: ProgressClosure?) -> Self {
        self.progressClosure = progressClosure
        return self
    }

}

extension NetTask: NetTaskProtocol {

    open var earliestBeginDate: Date? {
        get {
            guard #available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *) else {
                return nil
            }
            return netTask?.earliestBeginDate
        }
        set {
            if #available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *) {
                netTask?.earliestBeginDate = newValue
            }
        }
    }

    open func cancel() {
        state = .canceling
        netTask?.cancel()
    }

    open func suspend() {
        state = .suspended
        netTask?.suspend()
    }

    open func resume() {
        state = .running
        netTask?.resume()
    }

}

extension NetTask: Hashable {

    open var hashValue: Int {
        return identifier.hashValue
    }
    
}

extension NetTask: Equatable {

    open static func ==(lhs: NetTask, rhs: NetTask) -> Bool {
        return lhs.identifier == rhs.identifier
    }

}

extension NetTask: CustomStringConvertible {

    open var description: String {
        var description = String(describing: NetTask.self) + " " + identifier.description + " (" + String(describing: state) + ")"
        if let taskDescription = taskDescription {
            description = description + " " + taskDescription
        }
        return description
    }

}

extension NetTask: CustomDebugStringConvertible {

    open var debugDescription: String {
        return description
    }
    
}
