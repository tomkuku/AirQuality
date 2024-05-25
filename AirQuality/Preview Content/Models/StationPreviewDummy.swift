//
//  StationPreviewMock.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 12/05/2024.
//

import Foundation

extension Station {
    static func previewDummy(
        id: Int = 1,
        name: String = "AlKraKrak",
        latitude: Double = 11,
        longitude: Double = 12,
        cityName: String = "Kraków",
        commune: String = "Kraków",
        province: String = "Małopolskie",
        street: String = "al Krasińskiego 1"
    ) -> Self {
        Self(
            id: id,
            latitude: latitude,
            longitude: longitude,
            cityName: cityName,
            commune: commune,
            province: province,
            street: street
        )
    }
}
