//
//  UserLocationDataSourceSpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 16/06/2024.
//

import CoreLocation
import Combine

@testable import AirQuality

final class UserLocationDataSourceSpy: UserLocationDataSourceProtocol {
    func startUpdatingLocation() {
        
    }
    
    func stopUpdatingLocation() {
        
    }
    
    
    enum Event: Equatable {
        case getLocationServicesEnabled
        case getAuthorizationStatus
        case getLocationPublisher
        case getAuthorizationStatusPublisher
        case requestLocation
        case requestWhenInUseAuthorization
    }
    
    var events: [Event] = []
    
    var locationServicesEnabledReturnValue = false
    var authorizationStatusReturnValue: CLAuthorizationStatus = .denied
    var requestLocationHandler: (() -> ())?
    var requestWhenInUseAuthorizationHandler: (() -> ())?
    
    var locationSubject = PassthroughSubject<CLLocation, Error>()
    var autchorizationStatusSubject = PassthroughSubject<CLAuthorizationStatus, Never>()
    
    // MARK: UserLocationDataSourceProtocol
    
    var locationServicesEnabled: Bool {
        events.append(.getLocationServicesEnabled)
        return locationServicesEnabledReturnValue
    }
    
    var authorizationStatus: CLAuthorizationStatus {
        events.append(.getAuthorizationStatus)
        return authorizationStatusReturnValue
    }
    
    var locationPublisher: AnyPublisher<CLLocation, Error> {
        events.append(.getLocationPublisher)
        return locationSubject.eraseToAnyPublisher()
    }
    
    var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> {
        events.append(.getAuthorizationStatusPublisher)
        return autchorizationStatusSubject.eraseToAnyPublisher()
    }
    
    func requestLocation() {
        events.append(.requestLocation)
        requestLocationHandler?()
    }
    
    func requestWhenInUseAuthorization() {
        events.append(.requestWhenInUseAuthorization)
        requestWhenInUseAuthorizationHandler?()
    }
}
