//
//  NetURLSessionTaskObserver.swift
//  Net
//
//  Created by Alex Rupérez on 18/3/17.
//
//

import Foundation

class NetURLSessionTaskObserver: NSObject {

    private enum ObservedKeyPath: String {
        case countOfBytesReceived,
             countOfBytesSent,
             countOfBytesExpectedToSend,
             countOfBytesExpectedToReceive,
             state

        static let all = [countOfBytesReceived,
                          countOfBytesSent,
                          countOfBytesExpectedToSend,
                          countOfBytesExpectedToReceive,
                          state]
    }

    final var tasks = [URLSessionTask: NetTask]()

    func add(_ task: URLSessionTask, _ netTask: NetTask?) {
        tasks[task] = netTask
        for observedKeyPath in ObservedKeyPath.all {
            task.addObserver(self, forKeyPath: observedKeyPath.rawValue, options: .new, context: nil)
        }
    }

    deinit {
        for netTask in tasks.values {
            if netTask.progress == Progress.current() {
                netTask.progress.resignCurrent()
            }
            netTask.progress.cancel()
        }
        tasks.removeAll()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, let task = object as? URLSessionTask, let newValue = change?[.newKey] else {
            return
        }
        var taskProgress = tasks[task]?.progress
        if ObservedKeyPath(rawValue: keyPath) == .state, let intValue = newValue as? Int, let state = URLSessionTask.State(rawValue: intValue) {
            if let netState = NetTask.NetState(rawValue: state.rawValue) {
                tasks[task]?.state = netState
            }
            if state != .running {
                if taskProgress == Progress.current() {
                    taskProgress?.resignCurrent()
                }
                if state == .suspended {
                    taskProgress?.pause()
                } else {
                    if state == .canceling {
                        taskProgress?.cancel()
                    }
                    if taskProgress != nil {
                        for observedValue in ObservedKeyPath.all {
                            task.removeObserver(self, forKeyPath: observedValue.rawValue, context: context)
                        }
                    }
                    tasks[task] = nil
                    return
                }
            } else if #available(iOS 9.0, macOS 10.11, *), taskProgress?.isPaused == true {
                taskProgress?.resume()
            }
        }
        let completedUnitCount = max(task.countOfBytesReceived, task.countOfBytesSent)
        var totalUnitCount = max(task.countOfBytesExpectedToReceive, task.countOfBytesExpectedToSend)
        if let response = task.response as? HTTPURLResponse, let contentLengthString = response.allHeaderFields["X-Uncompressed-Content-Length"] as? String, let contentLength = Int64(contentLengthString) {
            totalUnitCount = contentLength
        }
        if taskProgress == nil {
            let progress = syncProgress(task, totalUnitCount: totalUnitCount)
            tasks[task]?.progress = progress
            progress.becomeCurrent(withPendingUnitCount: totalUnitCount)
            taskProgress = progress
        }
        taskProgress?.completedUnitCount = completedUnitCount
        taskProgress?.totalUnitCount = totalUnitCount
        if let task = tasks[task], let progress = taskProgress {
            task.progressClosure?(progress)
        }
    }

}

extension NetURLSessionTaskObserver {

    fileprivate func syncProgress(_ task: URLSessionTask, totalUnitCount: Int64) -> Progress {
        let taskProgress = Progress(totalUnitCount: totalUnitCount)
        taskProgress.isPausable = true
        taskProgress.isCancellable = true
        taskProgress.pausingHandler = { [weak task] in
            if task?.state != .suspended {
                task?.suspend()
            }
        }
        taskProgress.cancellationHandler = { [weak task] in
            if task?.state != .canceling {
                task?.cancel()
            }
        }
        if #available(iOS 9.0, macOS 10.11, *) {
            taskProgress.resumingHandler = { [weak task] in
                if task?.state != .running {
                    task?.resume()
                }
            }
        }
        return taskProgress
    }

}
