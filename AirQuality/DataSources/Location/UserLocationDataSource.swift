//
//  UserLocationDataSource.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 06/06/2024.
//

import Foundation
import CoreLocation
import Combine

protocol UserLocationDataSourceProtocol: AnyObject {
    var locationServicesEnabled: Bool { get }
    var authorizationStatus: CLAuthorizationStatus { get }
    
    var locationPublisher: AnyPublisher<CLLocation, Error> { get }
    var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> { get }
    
    func requestLocation()
    func requestWhenInUseAuthorization()
    
    func startUpdatingLocation()
    func stopUpdatingLocation()
}

final class UserLocationDataSource: NSObject, UserLocationDataSourceProtocol {
    
    // MARK: Properties
    
    var locationPublisher: AnyPublisher<CLLocation, Error> {
        locationSubject.eraseToAnyPublisher()
    }
    
    var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> {
        authorizationStatusSubject.eraseToAnyPublisher()
    }
    
    var locationServicesEnabled: Bool {
        locationManager.locationServicesEnabled()
    }
    
    var authorizationStatus: CLAuthorizationStatus {
        locationManager.authorizationStatus
    }
    
    // MARK: Private properties
    
    private let locationManager: CLLocationManagerProtocol
    private let locationSubject = PassthroughSubject<CLLocation, Error>()
    private var authorizationStatusSubject = PassthroughSubject<CLAuthorizationStatus, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Lifecycle
    
    init(locationManager: CLLocationManagerProtocol) {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.locationManager = locationManager
        
        super.init()
        
        self.locationManager.delegate = self
    }
    
    // MARK: Methods
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
}

// MARK: CLLocationManagerDelegate

extension UserLocationDataSource: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        locationSubject.send(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatusSubject.send(status)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationSubject.send(completion: .failure(error))
    }
}
