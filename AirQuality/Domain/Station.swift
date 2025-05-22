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
}
