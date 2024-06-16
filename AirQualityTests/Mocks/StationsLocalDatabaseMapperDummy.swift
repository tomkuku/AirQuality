//
//  StationsLocalDatabaseMapperDummy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 16/06/2024.
//

import Foundation

@testable import AirQuality

final class StationsLocalDatabaseMapperDummy: StationsLocalDatabaseMapperProtocol {
    typealias DomainModel = Station
    typealias DTOModel = StationLocalDatabaseModel
    
    func map(_ input: Station) throws -> StationLocalDatabaseModel {
        StationLocalDatabaseModel(
            identifier: 1,
            latitude: 0,
            longitude: 0,
            cityName: "",
            commune: "",
            province: "",
            street: ""
        )
    }
    
    func map(_ input: StationLocalDatabaseModel) throws -> Station {
        .dummy()
    }
}
