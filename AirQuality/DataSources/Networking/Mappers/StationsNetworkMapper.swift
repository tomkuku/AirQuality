//
//  StationsNetworkMapper.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 01/05/2024.
//

import Foundation

protocol HasStationsNetworkMapper {
    var stationsNetworkMapper: any StationsNetworkMapperProtocol { get }
}

protocol StationsNetworkMapperProtocol: NetworkMapperProtocol 
where DTOModel == [StationNetworkModel], DomainModel == [Station] { }

struct StationsNetworkMapper: StationsNetworkMapperProtocol {
    func map(_ input: [StationNetworkModel]) throws -> [Station] {
        try input.map {
            guard let latitude = Double($0.latitude), let longitude = Double($0.longitude) else {
                throw NSError(domain: "GetStationsResponseMapper", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Converting station latitude: \($0.latitude) or longitude: \($0.longitude) failed!"
                ])
            }
            
            return Station(
                id: $0.id,
                latitude: latitude,
                longitude: longitude,
                cityName: $0.city.name,
                commune: $0.city.commune.name,
                province: $0.city.commune.provinceName,
                street: $0.street
            )
        }
    }
}
