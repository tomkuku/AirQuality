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
}

extension Endpoint.Stations: HTTPRequest {
    var baseURL: String {
        switch self {
        case .get:
            "https://api.gios.gov.pl"
        }
    }
    
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
}
