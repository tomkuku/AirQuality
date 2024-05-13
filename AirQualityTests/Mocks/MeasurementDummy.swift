//
//  MeasurementDummy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 13/05/2024.
//

import Foundation

@testable import AirQuality

extension AirQuality.Measurement {
    static func dummy(
        date: Date = Date(),
        value: Double = 10.52
    ) -> Self {
        Self(
            date: date,
            value: value
        )
    }
}
