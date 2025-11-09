//
//  SensorArchivalMeasurementsListModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 21/05/2024.
//

import Foundation

enum SensorArchivalMeasurementsListModel {
    struct Section: Identifiable, Equatable {
        let name: String
        var rows: [Row]
        let year: Int
        let month: Int
        
        var id: String {
            name
        }
    }
    
    struct Row: Identifiable, Equatable {
        var id: String {
            formattedDate
        }
        
        let formattedValue: String
        let formattedDate: String
        
        let date: Date
    }
}
