//
//  StationLocalDatabaseModel+PreviewDummy.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 21/06/2024.
//

import Foundation

extension StationLocalDatabaseModel {
    static func previewDummy(
        identifier: Int = 1,
        latitude: Double = 11,
        longitude: Double = 12,
        cityName: String = "Kraków",
        commune: String = "Kraków",
        province: String = "Małopolskie",
        street: String? = "al Krasińskiego 1"
    ) -> Self {
        Self(
            identifier: identifier,
            latitude: latitude,
            longitude: longitude,
            cityName: cityName,
            commune: commune,
            province: province,
            street: street
        )
    }
}
