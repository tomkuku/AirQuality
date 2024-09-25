//
//  AllStationsListProvindesModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 25/09/2024.
//

import Foundation

enum AllStationsListProvindesModel {
    struct Province: Identifiable {
        var id: String {
            name
        }
        
        var numberOfStations: Int {
            stations.count
        }
        
        let name: String
        var stations: [Station] = []
    }
}
