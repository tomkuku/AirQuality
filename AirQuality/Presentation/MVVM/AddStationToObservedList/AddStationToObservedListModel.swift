//
//  AddStationToObservedListModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 26/05/2024.
//

import Foundation

enum AddStationToObservedListModel {
    struct Section: Identifiable {
        let name: String
        var rows: [Row]
        
        var id: String {
            name
        }
    }
    
    struct Row: Identifiable {
        let station: Station
        let isStationObserved: Bool
        
        var id: Int {
            station.id
        }
    }
}
