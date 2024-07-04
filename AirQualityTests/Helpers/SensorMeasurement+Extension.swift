//
//  SensorMeasurement+Extension.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 24/06/2024.
//

import Foundation

@testable import AirQuality

extension SensorMeasurement {
    init(value: Double, date: Date) {
        self.init(date: date, measurement: .init(value: value, unit: .microgramsPerCubicMeter))
    }
}
