//
//  NetURLSessionDelegate.swift
//  Net
//
//  Created by Alex Rupérez on 17/3/17.
//
//

import Foundation

class NetURLSessionDelegate: NSObject {

    fileprivate weak final var netURLSession: NetURLSession?

    final var tasks = [URLSessionTask: NetTask]()

    init(_ urlSession: NetURLSession) {
        netURLSession = urlSession
        super.init()
    }

    func add(_ task: URLSessionTask, _ netTask: NetTask?) {
        tasks[task] = netTask
    }

    deinit {
        tasks.removeAll()
        netURLSession = nil
    }

}

extension NetURLSessionDelegate: URLSessionDelegate {}

extension NetURLSessionDelegate: URLSessionTaskDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        handle(challenge, tasks[task], completion: completionHandler)
    }

    @available(iOS 10.0, tvOS 10.0, watchOS 3.0, macOS 10.12, *)
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting taskMetrics: URLSessionTaskMetrics) {
        if let netTask = tasks[task] {
            netTask.metrics = NetTaskMetrics(taskMetrics, request: netTask.request, response: netTask.response)
        }
        tasks[task] = nil
    }

    @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
    func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest request: URLRequest, completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) {
        completionHandler(.continueLoading, nil)
    }

    @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        if let netTask = tasks[task] {
            netTask.state = .waitingForConnectivity
        }
    }

}

extension NetURLSessionDelegate: URLSessionDataDelegate {}


extension NetURLSessionDelegate: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {}
    
}

@available(iOS 9.0, *)
extension NetURLSessionDelegate: URLSessionStreamDelegate {}

extension NetURLSessionDelegate {

    fileprivate func handle(_ challenge: URLAuthenticationChallenge, _ netTask: NetTask? = nil, completion: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        guard let authChallenge = netURLSession?.authChallenge else {
            guard challenge.previousFailureCount == 0 else {
                challenge.sender?.cancel(challenge)
                if let realm = challenge.protectionSpace.realm {
                    print(realm)
                    print(challenge.protectionSpace.authenticationMethod)
                }
                completion(.cancelAuthenticationChallenge, nil)
                return
            }

            var credential: URLCredential? = challenge.proposedCredential

            if credential?.hasPassword != true, challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic || challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPDigest, let request = netTask?.request {
                switch request.authorization {
                case .basic(let user, let password):
                    credential = URLCredential(user: user, password: password, persistence: .forSession)
                default:
                    break
                }
            }

            if credential == nil, challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust, let serverTrust = challenge.protectionSpace.serverTrust {
                let host = challenge.protectionSpace.host
                if let policy = netURLSession?.serverTrust[host] {
                    if policy.evaluate(serverTrust, host: host) {
                        credential = URLCredential(trust: serverTrust)
                    } else {
                        credential = nil
                    }
                } else {
                    credential = URLCredential(trust: serverTrust)
                }
            }

            completion(credential != nil ? .useCredential : .cancelAuthenticationChallenge, credential)
            return
        }
        authChallenge(challenge, completion)
    }

}
