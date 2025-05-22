//
//  DTOSensorsNetworkModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 22/05/2025.
//

import Foundation

protocol HasDTOSensorsNetworkMapper {
    var dtoSensorsNetworkMapper: any DTOSensorsNetworkMapperProtocol { get }
}

protocol DTOSensorsNetworkMapperProtocol: NetworkMapperProtocol
where DTOModel == [SensorNetworkModel], DomainModel == [DTO.Sensor] { }

struct DTOSensorsNetworkMapper: DTOSensorsNetworkMapperProtocol {
    func map(_ input: [SensorNetworkModel]) throws -> [DTO.Sensor] {
        input.map {
            DTO.Sensor(id: $0.id, paramId: $0.idParam)
        }
    }
}
