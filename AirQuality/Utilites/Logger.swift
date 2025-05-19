//
//  Logger.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 13/05/2024.
//

import OSLog
import Foundation
import Alamofire

enum Logger {
    private nonisolated(unsafe) static var subsystem = Bundle.main.bundleIdentifier! // swiftlint:disable:this force_unwrapping
    private static let logger = os.Logger(subsystem: subsystem, category: "statistics")
    
    static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
#if targetEnvironment(simulator)
        /// Do not log when tests
        guard !ProcessInfo.isUnitTests else { return }
#endif
        
        let logMessage: String = "⚙️ \(file.fileName):\(function):\(line)\n\(message)"
        logger.log("log, \(logMessage)")
        logger.debug("debug, \(logMessage)")
//        logger.info("\(logMessage)")
    }
    
    static func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
#if targetEnvironment(simulator)
        /// Do not log when tests
        guard !ProcessInfo.isUnitTests else { return }
#endif
        
        let logMessage: String = "🚨 \(file.fileName):\(function):\(line)\n\(message)"
        logger.error("\(logMessage)")
    }
}

fileprivate extension String {
    var fileName: String {
        (self as NSString).lastPathComponent
    }
}
