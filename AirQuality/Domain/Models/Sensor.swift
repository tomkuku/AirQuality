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
    let measurements: [AirQuality.Measurement]
    
    var precentValueOfLastMeasurement: Int {
        guard let value = measurements.last?.value else { return 0 }
        return Int((value / param.quota) * 100)
    }
}
