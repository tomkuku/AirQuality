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
        var stations: [Station]
        
        var id: String {
            name
        }
    }
    
    struct Row: Identifiable {
        var id: Int {
            station.id
        }
        
        let station: Station
        var isObserved: Bool
    }
}
