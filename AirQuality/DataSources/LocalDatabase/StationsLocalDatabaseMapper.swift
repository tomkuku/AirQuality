//
//  StationsLocalDatabaseMapper.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 27/05/2024.
//

import Foundation

protocol StationsLocalDatabaseMapperProtocol: LocalDatabaseMapperProtocol
where DTOModel == StationLocalDatabaseModel, DomainModel == Station { }

struct StationsLocalDatabaseMapper: StationsLocalDatabaseMapperProtocol {
    func mapDomainModel(_ input: Station) throws -> StationLocalDatabaseModel {
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
