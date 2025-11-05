//
//  StationsLocalDatabaseMapper.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 27/05/2024.
//

import Foundation

protocol HasStationsLocalDatabaseMapper {
    var stationsLocalDatabaseMapper: any StationsLocalDatabaseMapperProtocol { get }
}

protocol StationsLocalDatabaseMapperProtocol: LocalDatabaseMapperProtocol
where DomainModel == Station, DTOModel == StationLocalDatabaseModel, InputParameters == Void { }

struct StationsLocalDatabaseMapper: StationsLocalDatabaseMapperProtocol {
    typealias DomainModel = Station
    typealias DTOModel = StationLocalDatabaseModel
    typealias InputParameters = Void
    
    func map(_ input: Station) throws -> StationLocalDatabaseModel {
        StationLocalDatabaseModel(
            identifier: input.id,
            latitude: input.latitude,
            longitude: input.longitude,
            cityName: input.cityName,
            province: input.province,
            street: input.street
        )
    }
    
    func map(_ input: StationLocalDatabaseModel, using inputParameters: Void) throws -> Station {
        Station(
            id: input.identifier,
            latitude: input.latitude,
            longitude: input.longitude,
            cityName: input.cityName,
            province: input.province,
            street: input.street
        )
    }
}
