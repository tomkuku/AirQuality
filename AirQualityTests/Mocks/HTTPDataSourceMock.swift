//
//  HTTPDataSourceMock.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 04/05/2024.
//

import Foundation
import Alamofire

@testable import AirQuality

final class HTTPDataSourceMock: HTTPDataSourceProtocol, @unchecked Sendable {
    enum Event {
        case requestData
    }
    
    private(set) var events: [Event] = []
    
    var requestDataResult: Result<Data, Error> = .failure(ErrorDummy())
    
    func requestData<T>(
        _ urlRequest: T
    ) async throws -> Data where T: URLRequestConvertible {
        events.append(.requestData)
        
        switch requestDataResult {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }
}
