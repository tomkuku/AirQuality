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
    
    var formattedLastMeasurement: (date: String, value: String, percentageValue: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        var formattedDate = ""
        var formattedValue = "-"
        var formattedPercentageValue = "-"
        
        for measurement in measurements.reversed() {
            formattedDate = dateFormatter.string(from: measurement.date)
            
            if let value = measurement.value {
                formattedValue = String(format: "%.2f", value)
                formattedPercentageValue = "\(Int((value / param.quota) * 100))"
                break
            }
        }
        
        return (formattedDate, formattedValue, formattedPercentageValue)
    }
}
