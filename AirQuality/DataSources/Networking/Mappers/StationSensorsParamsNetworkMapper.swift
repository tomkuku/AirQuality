//
//  StationSensorsParamsNetworkMapper.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 03/07/2024.
//

import Foundation

protocol HasStationSensorsParamsNetworkMapper {
    var stationSensorsParamsNetworkMapper: any StationSensorsParamsNetworkMapperProtocol { get }
}

protocol StationSensorsParamsNetworkMapperProtocol: NetworkMapperProtocol
where DTOModel == [SensorNetworkModel], DomainModel == [Param] { }

final class StationSensorsParamsNetworkMapper: StationSensorsParamsNetworkMapperProtocol {
    func map(_ input: [SensorNetworkModel]) throws -> [Param] {
        input.compactMap {
            Param(id: $0.param.idParam)
        }
    }
}
