//
//  Measurement.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 13/05/2024.
//

import Foundation

struct Measurement: Equatable, Hashable {
    let date: Date
    let value: Double?
}
