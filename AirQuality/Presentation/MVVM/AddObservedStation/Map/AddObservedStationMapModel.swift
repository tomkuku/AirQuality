//
//  AddObservedStationMapModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 05/06/2024.
//

import Foundation
import CoreLocation

enum AddObservedStationMapModel {
    struct StationAnnotation: Identifiable {
        let station: Station
        let isStationObserved: Bool
        
        var id: Int {
            station.id
        }
        
        var coordinates: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: station.latitude, longitude: station.longitude)
        }
    }
}
