//
//  Location.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 05/06/2024.
//

import Foundation
import CoreLocation
import Combine

protocol HasLocationRespository {
    var locationRespository: LocationRespositoryProtocol { get }
}

protocol LocationRespositoryProtocol: AnyObject, Sendable {
    func isLocationServicesAvailble() -> Bool
    func requestLocation()
    func createLocationStream() -> AsyncThrowingStream<LocationCoordinates, Error>
}

final class LocationRespository: LocationRespositoryProtocol, Sendable {
    
    // MARK: Private properties
    
    private let locationDataSource: LocationDataSourceProtocol
    
    @Injected(\.notificationCenter) private var notificationCenter
    @Injected(\.locationCoordinatesMapper) private var locationCoordinatesMapper
    
    // MARK: Lifecycle
    
    init(locationDataSource: LocationDataSourceProtocol) {
        self.locationDataSource = locationDataSource
        
        self.observeLocationAuthorizationDidChange()
    }
    
    // MARK: Methods
    
    func isLocationServicesAvailble() -> Bool {
        guard locationDataSource.isLocationServicesEnabled() else {
            return false
        }
        
        return switch locationDataSource.getAuthorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
            true
        default:
            false
        }
    }
    
    func requestLocation() {
        switch locationDataSource.getAuthorizationStatus() {
        case .notDetermined:
            locationDataSource.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            locationDataSource.requestLocation()
        case .denied, .restricted:
            let error = NSError(domain: "LocationRespository", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Location services permission denied!"
            ])
        default:
            break
        }
    }
    
    func createLocationStream() -> AsyncThrowingStream<LocationCoordinates, Error> {
        AsyncThrowingStream { [weak self] continuation in
            Task { [weak self] in
                guard let self else {
                    continuation.finish()
                    return
                }
                
                do {
                    for try await location in self.locationDataSource.getLocationAsyncPublisher() {
                        let locationCoordinates = try self.locationCoordinatesMapper.map(location.coordinate)
                        continuation.yield(locationCoordinates)
                    }
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    // MARK: Private methods
    
    private func observeLocationAuthorizationDidChange() {
        Task { [weak self] in
            guard let self else { return }
            
            for await _ in NotificationCenter.default.notifications(named: .locationDataSourceDidChangeAuthorization, object: self.locationDataSource).map({ $0.name }) {
                self.requestLocation()
            }
        }
    }
}
