//
//  File.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 06/11/2025.
//

import Foundation

@testable import AirQuality

final class EnvironmentConstant: EnvironmentConstantsProtocol {
    var baseUrl: String {
        "http://test.com"
    }
}
