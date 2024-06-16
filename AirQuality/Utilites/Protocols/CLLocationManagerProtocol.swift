//
//  CLLocationManagerProtocol.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 06/06/2024.
//

import Foundation
import CoreLocation

protocol CLLocationManagerProtocol: AnyObject {
    var delegate: (any CLLocationManagerDelegate)? { get set }
    var desiredAccuracy: CLLocationAccuracy { get set }
    var authorizationStatus: CLAuthorizationStatus { get }
    
    func locationServicesEnabled() -> Bool
    
    func requestLocation()
    func requestWhenInUseAuthorization()
}

extension CLLocationManagerProtocol {
    func locationServicesEnabled() -> Bool {
        CLLocationManager.locationServicesEnabled()
    }
}

extension CLLocationManager: CLLocationManagerProtocol { }
