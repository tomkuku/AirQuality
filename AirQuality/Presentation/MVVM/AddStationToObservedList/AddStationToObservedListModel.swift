//
//  AddStationToObservedListModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 26/05/2024.
//

import Foundation

enum AddStationToObservedListModel {
    enum SortOption {
        case city
        case street
    }
    
    struct Sesction {
        let name: String
        var stations: [Station]
    }
}
