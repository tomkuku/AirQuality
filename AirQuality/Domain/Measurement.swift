//
//  Measurement.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 13/05/2024.
//

import Foundation

struct SensorMeasurement: Equatable, Hashable {
    let date: Date
    let measurement: Measurement<UnitConcentrationMass>?
}

extension UnitConcentrationMass {
    static let microgramsPerCubicMeter = UnitConcentrationMass(symbol: "µg/m³", converter: UnitConverterLinear(coefficient: 1e-6))
}
