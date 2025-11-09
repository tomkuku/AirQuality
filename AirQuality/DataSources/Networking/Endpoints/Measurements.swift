//
//  Measurements.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 13/05/2024.
//

import Foundation
import struct Alamofire.HTTPMethod

extension Endpoint.Measurements: HTTPRequest {
    var path: String {
        switch self {
        case .get(let id):
            "/pjp-api/v1/rest/data/getData/" + "\(id)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .get:
            .get
        }
    }
}
