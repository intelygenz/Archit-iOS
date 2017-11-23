//  LogManager.swift
//  Created by Alex Rupérez on 16/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import XCGLogger

let log: XCGLogger = {
    let log = XCGLogger(identifier: "advancedLogger", includeDefaultDestinations: false)
    log.levelDescriptions[.verbose] = "💜"
    log.levelDescriptions[.debug] = "💚"
    log.levelDescriptions[.info] = "💙"
    log.levelDescriptions[.warning] = "💛"
    log.levelDescriptions[.error] = "❤️"
    log.levelDescriptions[.severe] = "🖤"

    let consoleDestination = ConsoleDestination(identifier: "advancedLogger.consoleDestination")
    #if DEBUG
        consoleDestination.outputLevel = .debug
    #else
        consoleDestination.outputLevel = .severe
    #endif
    consoleDestination.showFunctionName = false
    consoleDestination.showFileName = false
    consoleDestination.showLineNumber = false
    log.add(destination: consoleDestination)

    return log
}()
