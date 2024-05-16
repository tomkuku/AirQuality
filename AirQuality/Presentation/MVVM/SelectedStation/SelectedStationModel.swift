//
//  SelectedStationModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 13/05/2024.
//

import Foundation

enum SelectedStationModel {
    struct Sensor: Identifiable {
        let id: Int
        let domainModel: AirQuality.Sensor
        let lastMeasurement: LastMeasurement
    }
    
    struct LastMeasurement {
        let measurement: Measurement?
        
        let percentageValue: Int?
        
        let formattedDate: String
        let formattedValue: String
        let formattedPercentageValue: String
    }
}
