//
//  File.swift
//  
//
//  Created by Tomasz Kukułka on 30/04/2024.
//

import Foundation
import Alamofire

protocol HTTPRequest: URLRequestConvertible, Equatable, Sendable {
    var baseURL: String { get }
    var path: String { get }
    var method: Alamofire.HTTPMethod { get }
    var params: [String: String]? { get }
}

extension HTTPRequest {
    var baseURL: String {
        AppConstant[.giosApiBaseUrl]
    }
    
    var params: [String: String]? {
        nil
    }
    
    func asURLRequest() throws -> URLRequest {
        guard var url = URLComponents(string: baseURL + path) else {
            throw AFError.invalidURL(url: baseURL)
        }
        
        url.queryItems = params?.map {
            URLQueryItem(name: $0.0, value: $0.1)
        }
        
        do {
            return try URLRequest(
                url: try url.asURL(),
                method: method
            )
        } catch {
            throw error
        }
    }
}
