//
//  UserLocationDataSourceSpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 16/06/2024.
//

import CoreLocation
import Combine
import XCTest

@testable import AirQuality

final class UserLocationDataSourceSpy: UserLocationDataSourceProtocol {
    
    enum Event: Equatable {
        case getLocationServicesEnabled
        case getAuthorizationStatus
        case getLocationPublisher
        case getAuthorizationStatusPublisher
        case requestLocation
        case requestWhenInUseAuthorization
        case startUpdatingLocation
        case stopUpdatingLocation
    }
    
    var events: [Event] = []
    
    var expectation: XCTestExpectation?
    
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
        expectation?.fulfill()
    }
    
    func requestWhenInUseAuthorization() {
        events.append(.requestWhenInUseAuthorization)
        requestWhenInUseAuthorizationHandler?()
        expectation?.fulfill()
    }
    
    func startUpdatingLocation() {
        events.append(.startUpdatingLocation)
        expectation?.fulfill()
    }
    
    func stopUpdatingLocation() {
        events.append(.stopUpdatingLocation)
        expectation?.fulfill()
    }
}
