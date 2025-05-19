//
//  Processinfo.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 21/05/2024.
//

import Foundation

extension ProcessInfo {
    static var isUnitTests: Bool {
        processInfo.arguments.contains(LaunchArgument.unitTests.rawValue)
    }
    
    static var isUITests: Bool {
        processInfo.arguments.contains(LaunchArgument.uiTests.rawValue)
    }
    
    static var isPreview: Bool {
        processInfo.environment[EnvironmentVariable.xcodeRunningForPreviews.rawValue] != nil
    }
    
    static func getEnvironment(_ environmentKey: EnvironmentVariable) -> Any? {
        processInfo.environment[environmentKey.rawValue]
    }
    
    static func containsArgument(_ argument: LaunchArgument) -> Bool {
        processInfo.arguments.contains(argument.rawValue)
    }
    
    enum LaunchArgument: String {
        case uiTests = "-ui-tests"
        case unitTests = "-unit-tests"
        case datatbaseStoreInMemoryOnly = "-datatbase-store-in-memory-only"
    }
    
    enum EnvironmentVariable: String {
        case uiTestsSqlitePath = "UITESTS_SQLITE_PATH"
        case xcodeRunningForPreviews = "XCODE_RUNNING_FOR_PREVIEWS"
    }
}
