//
//  Sensor.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import Foundation

struct Sensor: Sendable, Identifiable, Equatable {
    let id: Int
    let param: Param
    let measurements: [SensorMeasurement]
    
    var precentValueOfLastMeasurement: Int? {
        guard let value = measurements.last?.measurement?.value else { return nil }
        return Int((value / param.quota) * 100)
    }
}

extension Sensor: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
