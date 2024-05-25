//
//  SensorArchivalMeasurementsListModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 21/05/2024.
//

import Foundation

enum SensorArchivalMeasurementsListModel {
    struct Row {
        let formattedPercentageValue: String
        let formattedValue: String
        let formattedDate: String
        
        let value: Double
        let percentageValue: Double
        let date: Date
    }
}
