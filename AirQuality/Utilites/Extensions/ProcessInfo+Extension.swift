//
//  Processinfo.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 21/05/2024.
//

import Foundation

#if DEBUG || TESTS
extension ProcessInfo {
    static var isUnitTests: Bool {
        containsArgument(.unitTests)
    }
    
    static var isPreview: Bool {
        processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
    }
    
    static func containsArgument(_ argument: TestsLaunchArgument) -> Bool {
        processInfo.arguments.contains(argument.rawValue)
    }
    
    static func getEnvironment(_ environmentKey: TestsEnvironmentVariable) -> Any? {
        processInfo.environment[environmentKey.rawValue]
    }
}

enum TestsLaunchArgument: String {
    case uiTests = "-ui-tests"
    case unitTests = "-unit-tests"
    case specificDatabaseSqlitePath = "-specific-database-sqlite-path"
    case datatbaseStoreInMemoryOnly = "-datatbase-store-in-memory-only"
}

enum TestsEnvironmentVariable: String {
    case uiTestsSqlitePath = "UITESTS_SQLITE_PATH"
}
#endif
