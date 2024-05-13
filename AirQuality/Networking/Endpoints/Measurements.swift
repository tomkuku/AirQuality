//
//  Measurements.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 13/05/2024.
//

import Foundation
import struct Alamofire.HTTPMethod

extension Endpoint.Measurements: HTTPRequest {
    var baseURL: String {
        switch self {
        case .get:
            "https://api.gios.gov.pl"
        }
    }
    
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
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.get(lhsId), .get(rhsId)):
            lhsId == rhsId
        }
    }
}
