//
//  SensorsNetworkMapper.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import Foundation

public struct SensorsNetworkMapper: MapperProtocol {
    public init() { }
    
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
