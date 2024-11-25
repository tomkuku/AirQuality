//
//  ArchivalMeasurements.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 21/05/2024.
//

import Foundation
import struct Alamofire.HTTPMethod

extension Endpoint.ArchivalMeasurements: HTTPRequest {
    var path: String {
        switch self {
        case .get(let id):
            "/pjp-api/v1/rest/archivalData/getDataBySensor/" + "\(id)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .get:
                .get
        }
    }
    
    var params: [String: String]? {
        [
            "dayNumber": "366",
            "size": "500"
        ]
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.get(lhsId), .get(rhsId)):
            lhsId == rhsId
        }
    }
}
