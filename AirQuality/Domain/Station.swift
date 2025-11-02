//
//  Station.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 01/05/2024.
//

import Foundation

struct Station: Hashable, Sendable, Identifiable {
    let id: Int
    let latitude: Double
    let longitude: Double
    let cityName: String
    let province: String
    let street: String?
    
    private(set) var isObserved = false
    
    init(
        id: Int,
        latitude: Double,
        longitude: Double,
        cityName: String,
        province: String,
        street: String?,
        isObserved: Bool = false
    ) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.cityName = cityName
        self.province = province
        self.street = street
        self.isObserved = isObserved
    }
    
    mutating func setObservation(to isObserved: Bool) {
        self.isObserved = isObserved
    }
}
