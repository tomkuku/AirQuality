//
//  StationLocalDatabaseModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 27/05/2024.
//

import Foundation
import SwiftData

@Model
final class StationLocalDatabaseModel: Sendable {
    let id: Int
    let latitude: Double
    let longitude: Double
    let cityName: String
    let commune: String
    let province: String
    let street: String?
    
    init(
        id: Int,
        latitude: Double,
        longitude: Double,
        cityName: String,
        commune: String,
        province: String,
        street: String?
    ) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.cityName = cityName
        self.commune = commune
        self.province = province
        self.street = street
    }
}
