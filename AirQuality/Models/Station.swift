//
//  Station.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 01/05/2024.
//

import Foundation

public struct Station {
    let id: Int
    let name: String
    let latitude: Double // φ
    let longitude: Double // λ
    let cityName: String
    let commune: String
    let province: String
    let street: String
}
