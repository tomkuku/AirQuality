//
//  SensorsNetworkMapper.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import Foundation

struct SensorsNetworkMapper: MapperProtocol {
    func map(_ input: (SensorNetworkModel, Param, [Measurement])) throws -> Sensor {
        Sensor(id: input.0.id, param: input.1, measurements: input.2)
    }
}
