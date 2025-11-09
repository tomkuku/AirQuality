//
//  Endpoint.swift
//
//
//  Created by Tomasz Kukułka on 26/04/2024.
//

import Foundation
import Alamofire

enum Endpoint {
    enum Stations: Sendable {
        case get(page: Int, size: Int)
    }
    
    enum Sensors: Sendable {
        case get(Int)
    }
    
    enum Measurements: Sendable {
        case get(Int)
    }
    
    enum ArchivalMeasurements: Sendable {
        case get(
            sensorId: Int,
            page: Int,
            size: Int,
            options: SensorArchivalMeasurementsListOptions
        )
    }
}
