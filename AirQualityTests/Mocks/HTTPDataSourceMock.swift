//
//  HTTPDataSourceMock.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 04/05/2024.
//

import Foundation
import Alamofire
import Combine
import XCTest

@testable import AirQuality

final class HTTPDataSourceMock: HTTPDataSourceProtocol, @unchecked Sendable {
    enum Event: Equatable {
        case requestData((any URLRequestConvertible)?)
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case let (.requestData(lhsRequest), .requestData(rhsRequest)):
                guard let lhsURLRequest = lhsRequest?.urlRequest, let rhsURLRequest = rhsRequest?.urlRequest else {
                    return false
                }
                
                return lhsURLRequest == rhsURLRequest
            }
        }
    }
    
    private(set) var events: [Event] = []
    
    var requestDataResult: Result<Data, Error>?
    
    func requestData<T>(_ urlRequest: T) -> AnyPublisher<Data, Error> where T: URLRequestConvertible {
        events.append(.requestData(urlRequest))
        
        return Deferred {
            Future<Data, Error> { promise in
                switch self.requestDataResult {
                case .success(let data):
                    promise(.success(data))
                case .failure(let error):
                    promise(.failure(error))
                case .none:
                    XCTFail("Unhandled requestDataResult!")
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
