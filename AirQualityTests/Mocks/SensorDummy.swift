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
        param: Param = .pm10,
        measurements: [SensorMeasurement] = [.dummy()]
    ) -> Self {
        Self(
            id: id,
            param: param,
            measurements: measurements
        )
    }
}
