//
//  Processinfo.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 21/05/2024.
//

import Foundation

extension ProcessInfo {
    static var isTest: Bool {
        processInfo.environment["IS_TEST"] != nil
    }
    
    static var isUITests: Bool {
        processInfo.arguments.contains("-uitests")
    }
    
    static var isPreview: Bool {
        processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
    }
}
