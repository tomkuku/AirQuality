//
//  EndpointFake.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 04/05/2024.
//

import Foundation
import Alamofire

@testable import AirQuality

struct EndpointFake: HTTPRequest {
    var baseURL: String {
        "https://www.test.com"
    }
    
    var path: String {
        "/test"
    }
    
    var method: Alamofire.HTTPMethod {
        .get
    }
    
    var params: [String: String]? {
        ["key1": "value1"]
    }
}
