//
//  Sensors.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import Foundation
import struct Alamofire.HTTPMethod

extension Endpoint.Sensors: HTTPRequest {
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
    
    func createParams() throws -> [String: String]? {
        switch self {
        case .get:
            [
                "page": "0",
                "size": "100"
            ]
        }
    }
}
