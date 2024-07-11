//
//  HTTPDataStoreTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 04/05/2024.
//

import XCTest
import Foundation
import Alamofire
import Combine

@testable import AirQuality

final class HTTPDataStoreTests: BaseTestCase {
    
    private var sut: HTTPDataSource!
    
    override func setUp() {
        super.setUp()
        
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [URLProtocolMock.self]
        
        sut = HTTPDataSource(sessionConfiguration: configuration)
    }
    
    func testRequestDataWhenResponseIsSuccess() async throws {
        // Given
        let responseData = "test".data(using: .utf8)!
        
        let url = URL(string: "https://www.test.com")!
        
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        URLProtocolMock.result = .success((response, responseData))
        
        // When
        let data = try await sut.requestData(EndpointFake())
        
        // Then
        XCTAssertEqual(responseData, data)
    }
    
    func testRequestDataWhenResponseStatusCodeIsUnacceptable() async {
        // Given
        let responseData = "test".data(using: .utf8)!
        
        let url = URL(string: "https://www.test.com")!
        
        let response = HTTPURLResponse(
            url: url,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )!
        
        URLProtocolMock.result = .success((response, responseData))
        
        do {
            // When
            _ = try await sut.requestData(EndpointFake())
            XCTFail("RequestData should thrown error!")
        } catch {
            // Then
            guard
                let afError = error as? AFError,
                case .responseValidationFailed(let reason) = afError,
                case .unacceptableStatusCode(let code) = reason,
                code == 404
            else {
                XCTFail("Error should have been unacceptableStatusCode 404!")
                return
            }
        }
    }
    
    func testRequestDataWhenResponseIsFailure() async {
        // Given
        URLProtocolMock.result = .failure(ErrorDummy())
        
        do {
            // When
            _ = try await sut.requestData(EndpointFake())
            XCTFail("RequestData should thrown error!")
        } catch {
            // Then
            guard
                let afError = error as? AFError,
                case .sessionTaskFailed(let sessionTaskError) = afError,
                (sessionTaskError as NSError).domain == "AirQualityTests.ErrorDummy"
            else {
                XCTFail("Error should be equal to AFError.sessionTaskFailed with NSError!")
                return
            }
        }
    }
    
    private final class URLProtocolMock: URLProtocol, @unchecked Sendable {
        nonisolated(unsafe) static var result: Result<(HTTPURLResponse, Data), Error> = .failure(ErrorDummy())
        
        override static func canInit(with request: URLRequest) -> Bool {
            true
        }
        
        override static func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
        override func startLoading() {
            switch Self.result {
            case .success(let (response, data)):
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            case .failure(let error):
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() { }
    }
}
