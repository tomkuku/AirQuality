//
//  File.swift
//
//
//  Created by Tomasz Kukułka on 30/04/2024.
//

import Foundation
import Alamofire

protocol HTTPRequest: URLRequestConvertible, Sendable {
    var baseURL: String { get }
    var path: String { get }
    var method: Alamofire.HTTPMethod { get }
    
    func createParams() throws -> [String: String]?
}

extension HTTPRequest {
    var baseURL: String {
        EnvironmentConstant[\.baseUrl]
    }
    
    func createParams() throws -> [String: String]? {
        nil
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try (baseURL + path).asURL()
        var urlRequest = URLRequest(url: url)
        urlRequest.method = method
        
        let params = try createParams()
        
        return try URLEncoding.default.encode(urlRequest, with: params)
    }
}
