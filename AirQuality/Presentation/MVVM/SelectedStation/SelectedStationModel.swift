//
//  SelectedStationModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 13/05/2024.
//

import Foundation

enum SelectedStationModel {
    struct LastMeasurement: Sendable {
        let measurement: Measurement?
        
        let formattedDate: String
        let formattedValue: String
        let formattedPercentageValue: String
    }
}
