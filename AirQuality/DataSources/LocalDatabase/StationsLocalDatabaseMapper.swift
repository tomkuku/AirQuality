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
where DomainModel == Station, DTOModel == StationLocalDatabaseModel { }

struct StationsLocalDatabaseMapper: StationsLocalDatabaseMapperProtocol {
    typealias DomainModel = Station
    typealias DTOModel = StationLocalDatabaseModel
    
    func map(_ input: Station) throws -> StationLocalDatabaseModel {
        StationLocalDatabaseModel(
            identifier: input.id,
            latitude: input.latitude,
            longitude: input.longitude,
            cityName: input.cityName,
            commune: input.commune,
            province: input.province,
            street: input.street
        )
    }
    
    func map(_ input: StationLocalDatabaseModel) throws -> Station {
        Station(
            id: input.identifier,
            latitude: input.latitude,
            longitude: input.longitude,
            cityName: input.cityName,
            commune: input.commune,
            province: input.province,
            street: input.street
        )
    }
}
