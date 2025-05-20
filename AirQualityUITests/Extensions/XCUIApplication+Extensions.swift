//
//  XCUIApplication+Extensions.swift
//  AirQualityUITests
//
//  Created by Tomasz Kukułka on 20/05/2025.
//

import XCTest

@testable import AirQuality

extension XCUIApplication {
    @MainActor
    func setLaunchArguments(_ arguments: [TestsLaunchArgument]) {
        self.launchArguments = arguments.map { $0.rawValue }
    }
    
    @MainActor
    func setLaunchEnvironment(_ environment: [TestsEnvironmentVariable: String]) {
        self.launchEnvironment = environment.reduce(into: [:]) { all, env in
            all[env.key.rawValue] = env.value
        }
    }
}
