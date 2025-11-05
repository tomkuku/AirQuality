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
where DTOModel == [SensorNetworkModel], DomainModel == [Param], InputParameters == Void { }

final class StationSensorsParamsNetworkMapper: StationSensorsParamsNetworkMapperProtocol {
    func map(_ input: [SensorNetworkModel], using inputParameters: ()) throws -> [Param] {
        input.compactMap {
            Param(id: $0.idParam)
        }
    }
}
