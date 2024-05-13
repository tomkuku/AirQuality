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
        let name: String
        let formula: String
        let lastMeasurementValue: String
        let lastMeasurementDate: String
    }
}
