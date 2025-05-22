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
            "/pjp-api/v1/rest/station/findAll"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .get:
            .get
        }
    }
    
    var params: [String: String]? {
        switch self {
        case .get(let page, let size):
            [
                "page": "\(page)",
                "size": "\(size)"
            ]
        }
    }
}
