//
//  SensorDummy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 12/05/2024.
//

import Foundation

@testable import AirQuality

extension Sensor {
    static func dummy(
        id: Int = 1,
        name: String = "Particulate Matter PM10",
        formula: String = "PM10",
        code: String = "PM10"
    ) -> Self {
        Self(
            id: id,
            name: name,
            formula: formula,
            code: code
        )
    }
}
