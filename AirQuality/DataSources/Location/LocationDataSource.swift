//
//  LocationDataSource.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 06/06/2024.
//

import Foundation
import CoreLocation
import Combine

protocol LocationDataSourceProtocol: Sendable, AnyObject {
    func isLocationServicesEnabled() -> Bool
    func getAuthorizationStatus() -> CLAuthorizationStatus
    
    func getLocationAsyncPublisher() -> AsyncThrowingPublisher<AnyPublisher<CLLocation, Error>>
    func requestLocation()
    func requestWhenInUseAuthorization()
}

final class LocationDataSource: NSObject, LocationDataSourceProtocol, @unchecked Sendable {
    
    // MARK: Private properties
    
    private let locationManager: CLLocationManager
    private let subject = PassthroughSubject<CLLocation, Error>()
    
    @Injected(\.notificationCenter) private var notificationCeneter
    
    // MARK: Lifecycle
    
    init(locationManager: CLLocationManager) {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.locationManager = locationManager
        
        super.init()
        
        self.locationManager.delegate = self
    }
    
    // MARK: Methods
    
    func getLocationAsyncPublisher() -> AsyncThrowingPublisher<AnyPublisher<CLLocation, Error>> {
        AsyncThrowingPublisher(subject.eraseToAnyPublisher())
    }
    
    func isLocationServicesEnabled() -> Bool {
        locationManager.locationServicesEnabled()
    }
    
    func getAuthorizationStatus() -> CLAuthorizationStatus {
        locationManager.authorizationStatus
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
}

// MARK: CLLocationManagerDelegate

extension LocationDataSource: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        subject.send(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        notificationCeneter.post(name: .locationDataSourceDidChangeAuthorization, object: self)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        subject.send(completion: .failure(error))
    }
}
