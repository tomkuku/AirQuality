//
//  CLLocationManagerSpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 13/06/2024.
//

import Foundation
import CoreLocation

@testable import AirQuality

final class CLLocationManagerSpy: CLLocationManagerProtocol {
    
    enum Event: Equatable {
        case requestLocation
        case requestWhenInUseAuthorization
        case locationServicesEnabled
        case delegateDidSet((any CLLocationManagerDelegate)?)
        case desiredAccuracyDidSet(CLLocationAccuracy)
        case authorizationStatusDidGet
        case startUpdatingLocation
        case stopUpdatingLocation
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case
                (.requestLocation, .requestLocation),
                (.requestWhenInUseAuthorization, .requestWhenInUseAuthorization),
                (.locationServicesEnabled, .locationServicesEnabled),
                (.startUpdatingLocation, .startUpdatingLocation),
                (.stopUpdatingLocation, .stopUpdatingLocation):
                true
            case let (.delegateDidSet(lhsDelegate), .delegateDidSet(rhsDelegate)):
                lhsDelegate === rhsDelegate
            case let (.desiredAccuracyDidSet(lhsAccuracy), .desiredAccuracyDidSet(rhsAccuracy)):
                lhsAccuracy == rhsAccuracy
            case (.authorizationStatusDidGet, .authorizationStatusDidGet):
                true
            default:
                false
            }
        }
    }
    
    var events: [Event] = []
    
    var locationServicesEnabledReturnValue = false
    var authorizationStatusReturnValue: CLAuthorizationStatus = .notDetermined
    
    var delegate: (any CLLocationManagerDelegate)? {
        didSet {
            events.append(.delegateDidSet(delegate))
        }
    }
    
    var desiredAccuracy: CLLocationAccuracy = .pi {
        didSet {
            events.append(.desiredAccuracyDidSet(desiredAccuracy))
        }
    }
    
    func startUpdatingLocation() {
        events.append(.startUpdatingLocation)
    }
    
    func stopUpdatingLocation() {
        events.append(.stopUpdatingLocation)
    }
    
    var authorizationStatus: CLAuthorizationStatus {
        events.append(.authorizationStatusDidGet)
        return authorizationStatusReturnValue
    }
    
    func requestLocation() {
        events.append(.requestLocation)
    }
    
    func requestWhenInUseAuthorization() {
        events.append(.requestWhenInUseAuthorization)
    }
    
    func locationServicesEnabled() -> Bool {
        events.append(.locationServicesEnabled)
        
        return locationServicesEnabledReturnValue
    }
}
