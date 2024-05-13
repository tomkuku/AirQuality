//
//  SensorsNetworkMapper.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import Foundation

struct SensorsNetworkMapper: MapperProtocol {
    func map(_ input: [SensorNetworkModel]) throws -> [Sensor] {
        input.map {
            Sensor(
                id: $0.id,
                name: $0.name,
                formula: $0.formula,
                code: $0.code
            )
        }
    }
}
