//
//  MeasurementDummy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 13/05/2024.
//

import XCTest

@testable import AirQuality

extension SensorMeasurement {
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter
    }()
    
    static func dummy(
        value: Double = 10.52
    ) -> Self {
        let measurement = Measurement<UnitConcentrationMass>(value: value, unit: .microgramsPerCubicMeter)
        
        return Self(date: Date(), measurement: measurement)
    }
    
    static func dummy(
        date: String = "2024-06-25 15:00",
        value: Double = 10.52
    ) -> Self {
        let measurement = Measurement<UnitConcentrationMass>(value: value, unit: .microgramsPerCubicMeter)
        
        let measurementDate: Date
        
        if let formattedDate = dateFormatter.date(from: date) {
            measurementDate = formattedDate
        } else {
            XCTFail("Formatting string \(date) to date failed!")
            measurementDate = Date()
        }
        
        return Self(date: measurementDate, measurement: measurement)
    }
}
