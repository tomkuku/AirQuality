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

protocol SensorsNetworkMapperProtocol: NetworkMapperProtocol
where DTOModel == SensorNetworkModel,
      DomainModel == Sensor,
      InputParameters == (param: Param, measurements: [SensorMeasurement]) {}

struct SensorsNetworkMapper: SensorsNetworkMapperProtocol {
    func map(_ input: SensorNetworkModel, using inputParameters: (param: Param, measurements: [SensorMeasurement])) throws -> Sensor {
        Sensor(
            id: input.id,
            param: inputParameters.param,
            measurements: inputParameters.measurements
        )
    }
}
