//
//  Stations.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import Foundation
import struct Alamofire.HTTPMethod

extension Endpoint.Stations: HTTPRequest {
    var path: String {
        switch self {
        case .get:
            "/pjp-api/rest/station/findAll"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .get:
            .get
        }
    }
}
