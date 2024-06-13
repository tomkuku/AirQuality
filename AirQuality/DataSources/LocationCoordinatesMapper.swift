//
//  LocationCoordinatesMapper.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 06/06/2024.
//

import Foundation
import struct CoreLocation.CLLocationCoordinate2D

protocol HasLocationCoordinatesMapper {
    var locationCoordinatesMapper: any LocationCoordinatesMapperProtocol { get }
}

protocol LocationCoordinatesMapperProtocol: MapperProtocol, Sendable
where DomainModel == LocationCoordinates, DTOModel == CLLocationCoordinate2D { }

final class LocationCoordinatesMapper: LocationCoordinatesMapperProtocol {
    func map(_ input: CLLocationCoordinate2D) throws -> LocationCoordinates {
        LocationCoordinates(latitude: input.latitude, longitude: input.longitude)
    }
}
