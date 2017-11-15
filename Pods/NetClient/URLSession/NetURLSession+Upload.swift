//
//  NetURLSession+Upload.swift
//  Net
//
//  Created by Alex Rupérez on 17/3/17.
//
//

extension NetURLSession {

    open func upload(_ streamedRequest: NetRequest) -> NetTask {
        let task = session.uploadTask(withStreamedRequest: urlRequest(streamedRequest))
        let netUploadTask = netTask(task, streamedRequest)
        observe(task, netUploadTask)
        return netUploadTask
    }

    open func upload(_ streamedRequest: URLRequest) throws -> NetTask {
        guard let netRequest = streamedRequest.netRequest else {
            throw netError(URLError(.badURL))!
        }
        return upload(netRequest)
    }

    open func upload(_ streamedURL: URL, cachePolicy: NetRequest.NetCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) -> NetTask {
        return upload(netRequest(streamedURL, cache: cachePolicy, timeout: timeoutInterval))
    }

    open func upload(_ streamedURLString: String, cachePolicy: NetRequest.NetCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) throws -> NetTask {
        guard let url = URL(string: streamedURLString) else {
            throw netError(URLError(.badURL))!
        }
        return upload(url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
    }

    open func upload(_ request: NetRequest, data: Data) -> NetTask {
        var netUploadTask: NetTask?
        let task = session.uploadTask(with: urlRequest(request), from: data) { [weak self] (data, response, error) in
            let netResponse = self?.netResponse(response, netUploadTask, data)
            let netError = self?.netError(error, data, response)
            self?.process(netUploadTask, netResponse, netError)
        }
        netUploadTask = netTask(task, request)
        observe(task, netUploadTask)
        return netUploadTask!
    }

    open func upload(_ request: URLRequest, data: Data) throws -> NetTask {
        guard let netRequest = request.netRequest else {
            throw netError(URLError(.badURL))!
        }
        return upload(netRequest, data: data)
    }

    open func upload(_ url: URL, data: Data, cachePolicy: NetRequest.NetCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) -> NetTask {
        return upload(netRequest(url, cache: cachePolicy, timeout: timeoutInterval), data: data)
    }

    open func upload(_ urlString: String, data: Data, cachePolicy: NetRequest.NetCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) throws -> NetTask {
        guard let url = URL(string: urlString) else {
            throw netError(URLError(.badURL))!
        }
        return upload(url, data: data, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
    }

    open func upload(_ request: NetRequest, fileURL: URL) -> NetTask {
        var netUploadTask: NetTask?
        let task = session.uploadTask(with: urlRequest(request), fromFile: fileURL) { [weak self] (data, response, error) in
            let netResponse = self?.netResponse(response, netUploadTask, data)
            let netError = self?.netError(error, data, response)
            self?.process(netUploadTask, netResponse, netError)
        }
        netUploadTask = netTask(task, request)
        observe(task, netUploadTask)
        return netUploadTask!
    }

    open func upload(_ request: URLRequest, fileURL: URL) throws -> NetTask {
        guard let netRequest = request.netRequest else {
            throw netError(URLError(.badURL))!
        }
        return upload(netRequest, fileURL: fileURL)
    }

    open func upload(_ url: URL, fileURL: URL, cachePolicy: NetRequest.NetCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) -> NetTask {
        return upload(netRequest(url, cache: cachePolicy, timeout: timeoutInterval), fileURL: fileURL)
    }

    open func upload(_ urlString: String, fileURL: URL, cachePolicy: NetRequest.NetCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) throws -> NetTask {
        guard let url = URL(string: urlString) else {
            throw netError(URLError(.badURL))!
        }
        return upload(url, fileURL: fileURL, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
    }

}
