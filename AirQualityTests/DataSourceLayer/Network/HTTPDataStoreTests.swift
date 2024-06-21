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
    
    func testRequestDataWhenResponseIsSuccess() {
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
        
        var data: Data?
        
        // When
        sut.requestData(EndpointFake())
            .sink {
                guard case .failure = $0 else { return }
                XCTFail("requestData should not have published any error!")
            } receiveValue: {
                data = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(responseData, data)
    }
    
    func testRequestDataWhenResponseStatusCodeIsUnacceptable() {
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
        
        var error: Error?
        
        // When
        sut.requestData(EndpointFake())
            .sink {
                guard case .failure(let failureError) = $0 else { return }
                
                error = failureError
                self.expectation.fulfill()
            } receiveValue: { _ in
                XCTFail("requestData should not have published any value!")
            }
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
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
    
    func testRequestDataWhenResponseIsFailure() {
        // Given
        URLProtocolMock.result = .failure(ErrorDummy())
        
        var error: Error?
        
        // When
        sut.requestData(EndpointFake())
            .sink {
                guard case .failure(let failureError) = $0 else { return }
                
                error = failureError
                self.expectation.fulfill()
            } receiveValue: { _ in
                XCTFail("requestData should not have published any value!")
            }
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        guard
            let afError = error as? AFError,
            case .sessionTaskFailed(let sessionTaskError) = afError,
            (sessionTaskError as NSError).domain == "AirQualityTests.ErrorDummy"
        else {
            XCTFail("Error should be equal to AFError.sessionTaskFailed with NSError!")
            return
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
