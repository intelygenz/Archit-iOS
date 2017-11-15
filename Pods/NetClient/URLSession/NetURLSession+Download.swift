//
//  NetURLSession+Download.swift
//  Net
//
//  Created by Alex Rupérez on 17/3/17.
//
//

extension NetURLSession {

    open func download(_ resumeData: Data) -> NetTask {
        var netDownloadTask: NetTask?
        let task = session.downloadTask(withResumeData: resumeData) { [weak self] (url, response, error) in
            let netResponse = self?.netResponse(response, netDownloadTask, url)
            let netError = self?.netError(error, url, response)
            self?.process(netDownloadTask, netResponse, netError)
        }
        netDownloadTask = netTask(task)
        observe(task, netDownloadTask)
        return netDownloadTask!
    }

    open func download(_ request: NetRequest) -> NetTask {
        var netDownloadTask: NetTask?
        let task = session.downloadTask(with: urlRequest(request)) { [weak self] (url, response, error) in
            let netResponse = self?.netResponse(response, netDownloadTask, url)
            let netError = self?.netError(error, url, response)
            self?.process(netDownloadTask, netResponse, netError)
        }
        netDownloadTask = netTask(task, request)
        observe(task, netDownloadTask)
        return netDownloadTask!
    }

    open func download(_ request: URLRequest) throws -> NetTask {
        guard let netRequest = request.netRequest else {
            throw netError(URLError(.badURL))!
        }
        return download(netRequest)
    }

    open func download(_ url: URL, cachePolicy: NetRequest.NetCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) -> NetTask {
        return download(netRequest(url, cache: cachePolicy, timeout: timeoutInterval))
    }

    open func download(_ urlString: String, cachePolicy: NetRequest.NetCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) throws -> NetTask {
        guard let url = URL(string: urlString) else {
            throw netError(URLError(.badURL))!
        }
        return download(url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
    }

}
