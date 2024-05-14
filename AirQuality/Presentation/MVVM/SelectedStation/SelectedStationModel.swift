//
//  SelectedStationModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 13/05/2024.
//

import Foundation

enum SelectedStationModel {
    struct Sensor: Sendable, Identifiable {
        let id: Int
        let param: Param
        let measurements: [Measurement]
        
        private let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            return formatter
        }()
        
        var formattedLastMeasurement: (String, String) {
            var formattedDate: String?
            var formattedValue: String?
            
            measurements.forEach { measurement in
                guard let measurementValue = measurement.value else { return }
                
                formattedDate = dateFormatter.string(from: measurement.date)
                formattedValue = String(format: "%.2f", measurementValue)
            }
            
            return (formattedDate ?? "no date", formattedValue ?? "no value")
        }
    }
}
