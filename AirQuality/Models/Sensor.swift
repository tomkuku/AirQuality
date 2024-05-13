//
//  Sensor.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import Foundation

struct Sensor: Sendable, Identifiable, Equatable {
    let id: Int
    let name: String
    let formula: String
    let code: String
    var measurements: [AirQuality.Measurement] = []
}
