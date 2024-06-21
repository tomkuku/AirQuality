//
//  MeasurementNetworkModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 13/05/2024.
//

import Foundation

struct MeasurementNetworkModel: Decodable, Equatable {
    enum CodingKeys: String, CodingKey {
        case date = "Data"
        case value = "Wartość"
    }
    
    let date: String
    let value: Double?
}
