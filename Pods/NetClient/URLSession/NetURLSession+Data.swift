//
//  NetURLSession+Data.swift
//  Net
//
//  Created by Alex Rupérez on 17/3/17.
//
//

extension NetURLSession {

    open func data(_ request: NetRequest) -> NetTask {
        var netDataTask: NetTask?
        let task = session.dataTask(with: urlRequest(request)) { [weak self] (data, response, error) in
            let netResponse = self?.netResponse(response, netDataTask, data)
            let netError = self?.netError(error, data, response)
            self?.process(netDataTask, netResponse, netError)
        }
        netDataTask = netTask(task, request)
        observe(task, netDataTask)
        return netDataTask!
    }

    open func data(_ request: URLRequest) throws -> NetTask {
        guard let netRequest = request.netRequest else {
            throw netError(URLError(.badURL))!
        }
        return data(netRequest)
    }

    open func data(_ url: URL, cachePolicy: NetRequest.NetCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) -> NetTask {
        return data(netRequest(url, cache: cachePolicy, timeout: timeoutInterval))
    }

    open func data(_ urlString: String, cachePolicy: NetRequest.NetCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) throws -> NetTask {
        guard let url = URL(string: urlString) else {
            throw netError(URLError(.badURL))!
        }
        return data(url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
    }

}
