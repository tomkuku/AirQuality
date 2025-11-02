//
//  FindTheNearestStationUseCase.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 06/06/2024.
//

import Foundation
import class CoreLocation.CLLocation

protocol HasFindTheNearestStationUseCase {
    var findTheNearestStationUseCase: FindTheNearestStationUseCaseProtocol { get }
}

protocol FindTheNearestStationUseCaseProtocol: Sendable {
    func find() async throws -> (station: Station, distance: Double)?
}

actor FindTheNearestStationUseCase: FindTheNearestStationUseCaseProtocol {
    @Injected(\.locationRespository) private var locationRespository
    @Injected(\.giosApiV1Repository) private var giosApiV1Repository
    @Injected(\.stationsNetworkMapper) private var stationsNetworkMapper
    
    func find() async throws -> (station: Station, distance: Double)? {
        async let fetchedStations = giosApiV1Repository.fetch(
            mapper: stationsNetworkMapper,
            endpoint: Endpoint.Stations.get(page: 0, size: 1),
            contentContainerName: .stations
        )
        
        async let userLocation = locationRespository.requestLocationOnce()
        
        var theNearestStation: Station?
        var minDistance: Double = .greatestFiniteMagnitude
        
        for station in try await fetchedStations {
            let stationLocation = CLLocation(latitude: station.latitude, longitude: station.longitude)
            let distance = try await userLocation?.distance(from: stationLocation)
            
            if (distance ?? .infinity) < minDistance {
                minDistance = distance ?? .infinity
                theNearestStation = station
            }
        }
        
        guard let theNearestStation else {
            Logger.error("The nearest station is nil!")
            return nil
        }
        
        return (theNearestStation, minDistance)
    }
}
