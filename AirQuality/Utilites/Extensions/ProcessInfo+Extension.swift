//
//  Processinfo.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 21/05/2024.
//

import Foundation

extension ProcessInfo {
    static var isUnitTests: Bool {
        processInfo.arguments.contains("-unit-tests")
    }
    
    static var isUITests: Bool {
        processInfo.arguments.contains("-ui-tests")
    }
    
    static var isPreview: Bool {
        processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
    }
}
