//
//  SensorsNetworkMapper.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import Foundation

protocol HasSensorsNetworkMapper {
    var sensorsNetworkMapper: any SensorsNetworkMapperProtocol { get }
}

protocol SensorsNetworkMapperProtocol: MapperProtocol
where DTOModel == (SensorNetworkModel, Param, [SensorMeasurement]), DomainModel == Sensor {
    func map(_ input: (SensorNetworkModel, Param, [SensorMeasurement])) throws -> Sensor
}

struct SensorsNetworkMapper: SensorsNetworkMapperProtocol {
    func map(_ input: (SensorNetworkModel, Param, [SensorMeasurement])) throws -> Sensor {
        Sensor(id: input.0.id, param: input.1, measurements: input.2)
    }
}
