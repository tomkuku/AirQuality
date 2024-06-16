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
    @Injected(\.giosApiRepository) private var giosApiRepository
    @Injected(\.stationsNetworkMapper) private var stationsNetworkMapper
    
    func find() async throws -> (station: Station, distance: Double)? {
        async let fetchedStations =  giosApiRepository.fetch(
            mapper: stationsNetworkMapper,
            endpoint: Endpoint.Stations.get,
            source: .cacheIfPossible
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
