//
//  Sensors.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import Foundation
import struct Alamofire.HTTPMethod

extension Endpoint.Sensors: HTTPRequest {
    var baseURL: String {
        switch self {
        case .get:
            "https://api.gios.gov.pl"
        }
    }
    
    var path: String {
        switch self {
        case .get(let id):
            "/pjp-api/v1/rest/station/sensors/" + "\(id)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .get:
            .get
        }
    }
    
    static func == (lhs: Endpoint.Sensors, rhs: Endpoint.Sensors) -> Bool {
        switch (lhs, rhs) {
        case let (.get(lhsId), .get(rhsId)):
            lhsId == rhsId
        }
    }
}
