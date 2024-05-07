//
//  StationsNetworkMapper.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 01/05/2024.
//

import Foundation

public struct StationsNetworkMapper: MapperProtocol {
    public init() { }
    
    func map(_ input: [StationNetworkModel]) throws -> [Station] {
        try input.map {
            guard let latitude = Double($0.latitude), let longitude = Double($0.longitude) else {
                throw NSError(domain: "GetStationsResponseMapper", code: -1, userInfo: [
                    NSLocalizedDescriptionKey:  "Converting station latitude: \($0.latitude) or longitude: \($0.longitude) failed!"
                ])
            }
            
            return Station(
                id: $0.id,
                name: $0.name,
                latitude: latitude,
                longitude: longitude,
                cityName: $0.cityName,
                commune: $0.commune,
                province: $0.province,
                street: $0.street
            )
        }
    }
}
