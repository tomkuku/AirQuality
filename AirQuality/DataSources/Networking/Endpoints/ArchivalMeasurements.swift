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
        case .get(let id, _, _, _, _, _):
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
        switch self {
        case .get(_, let page, let size, let dateFrom, let dateTo, let sort):
            [
                "page": "\(page)",
                "size": "\(size)",
                "dateTo": dateTo,
                "dateFrom": dateFrom,
                "sort": sort
            ]
        }
    }
    
//    static func == (lhs: Self, rhs: Self) -> Bool {
//        switch (lhs, rhs) {
//        case let (.get(lhsId), .get(rhsId)):
//            lhsId == rhsId
//        }
//    }
}
