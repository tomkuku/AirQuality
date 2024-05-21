//
//  Endpoint.swift
//
//
//  Created by Tomasz Kukułka on 26/04/2024.
//

import Foundation
import Alamofire

enum Endpoint {
    enum Stations {
        case get
    }
    
    enum Sensors {
        case get(Int)
    }
    
    enum Measurements {
        case get(Int)
    }
    
    enum ArchivalMeasurements {
        case get(Int)
    }
}
