//
//  NetTask+URLSessionTask.swift
//  Net
//
//  Created by Alex Rupérez on 25/3/17.
//
//

import Foundation

extension NetTask {

    public convenience init(_ urlSessionTask: URLSessionTask, request: NetRequest? = nil, response: NetResponse? = nil, error: NetError? = nil) {
        self.init(urlSessionTask.taskIdentifier, request: request, response: response, taskDescription: urlSessionTask.taskDescription, state: NetState(rawValue: urlSessionTask.state.rawValue) ?? .suspended, error: error, priority: urlSessionTask.priority, task: urlSessionTask)
    }
    
}

extension URLSessionTask: NetTaskProtocol {}
