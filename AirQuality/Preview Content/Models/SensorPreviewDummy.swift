//
//  SensorPreviewDummy.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 12/05/2024.
//

import Foundation

extension Sensor {
    static func previewDummy(
        id: Int = 1,
        param: Param = .c6h6
    ) -> Self {
        let measurements: [Measurement] = [
            Measurement(date: Date(), value: Double.random(in: 0...100)),
            Measurement(date: Date(), value: Double.random(in: 0...100)),
            Measurement(date: Date(), value: Double.random(in: 0...100))
        ]
        
        return Self(
            id: id,
            param: param,
            measurements: measurements
        )
    }
}
