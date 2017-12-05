//  LogManager.swift
//  Created by Alex Rupérez on 16/11/17.
//  Copyright © 2017 Intelygenz. All rights reserved.

import XCGLogger
import Core
import Domain

struct LogManager {
    static func configure() {
        let logger = XCGLogger(identifier: "advancedLogger", includeDefaultDestinations: false)
        logger.levelDescriptions[.verbose] = "💜"
        logger.levelDescriptions[.debug] = "💚"
        logger.levelDescriptions[.info] = "💙"
        logger.levelDescriptions[.warning] = "💛"
        logger.levelDescriptions[.error] = "❤️"
        logger.levelDescriptions[.severe] = "🖤"

        let consoleDestination = ConsoleDestination(identifier: "advancedLogger.consoleDestination")
        #if DEBUG
            consoleDestination.outputLevel = .debug
        #else
            consoleDestination.outputLevel = .severe
        #endif
        consoleDestination.showFunctionName = false
        consoleDestination.showFileName = false
        consoleDestination.showLineNumber = false
        logger.add(destination: consoleDestination)

        log = logger
        Core.log = logger
        Domain.log = logger
    }
}
