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
    
    @HandlerActor
    func find() async throws -> (station: Station, distance: Double)? {
        async let fetchedStations = giosApiRepository.fetch(
            mapper: stationsNetworkMapper,
            endpoint: Endpoint.Stations.get,
            source: .cacheIfPossible
        )
        
        guard let userLocation = try await getUserLocation() else {
            Logger.error("User location nil!")
            return nil
        }
        
        var theNearestStation: Station?
        var minDistance: Double = .greatestFiniteMagnitude
        
        for station in try await fetchedStations {
            let stationLocation = CLLocation(latitude: station.latitude, longitude: station.longitude)
            
            let distance = userLocation.distance(from: stationLocation)
            
            if distance < minDistance {
                minDistance = distance
                theNearestStation = station
            }
        }
        
        guard let theNearestStation else {
            Logger.error("The nearest station not found!")
            return nil
        }
        
        return (theNearestStation, minDistance)
    }
    
    private func getUserLocation() async throws -> CLLocation? {
        locationRespository.requestLocation()
        
        for try await coordinates in locationRespository.createLocationStream() {
            return CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        }
        
        return nil
    }
}
