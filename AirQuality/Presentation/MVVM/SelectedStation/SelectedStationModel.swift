//
//  SelectedStationModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 13/05/2024.
//

import Foundation

enum SelectedStationModel {
    struct SensorRow: Identifiable {
        let id: Int
        let paramName: String
        let paramFormula: String
        
        let lastMeasurementAqi: AQI
        let lastMeasurementPercentageValue: Double?
        
        let lastMeasurementFormattedDate: String
        let lastMeasurementFormattedValue: String
        let lastMeasurementFormattedPercentageValue: String
    }
}
