//
//  HTTPDataStoreTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 04/05/2024.
//

import XCTest
import Foundation
import Alamofire

@testable import AirQuality

final class HTTPDataStoreTests: BaseTestCase {
    
    private var sut: HTTPDataSource!
    
    override func setUp() {
        super.setUp()
        
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [URLProtocolMock.self]
        
        let session = Session(configuration: configuration)
        
        sut = HTTPDataSource(session: session)
    }
    
    func testRequestDataWhenResponseIsSuccess() async throws {
        // Given
        let data = "test".data(using: .utf8)!
            
        let url = URL(string: "https://www.test.com")!
        
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        URLProtocolMock.result = .success((response, data))
        
        // When
        let responseData = try await sut.requestData(EndpointFake())
        
        // Then
        XCTAssertEqual(responseData, data)
    }
    
    func testRequestDataWhenResponseStatusCodeIsUnacceptable() async throws {
        // Given
        let data = "test".data(using: .utf8)!
            
        let url = URL(string: "https://www.test.com")!
        
        let response = HTTPURLResponse(
            url: url,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )!
        
        URLProtocolMock.result = .success((response, data))
        
        // When
        do {
            _ = try await sut.requestData(EndpointFake())
            XCTFail("requestData should have throw!")
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
    
    // "API-ERR-100003" // 429
    func testRequestDataWhenResponseIsFailure() async {
        // Given
        URLProtocolMock.result = .failure(ErrorDummy())
        
        do {
            // When
            _ = try await sut.requestData(EndpointFake())
            XCTFail("requestData should have throw!")
        } catch {
            // Then
            print(error)
            guard
                let afError = error as? AFError,
                case .sessionTaskFailed(let sessionTaskError) = afError,
                (sessionTaskError as NSError).domain == "AirQualityTests.ErrorDummy"
            else {
                XCTFail("Error should have been equal to sessionTaskFailed")
                return
            }
            
            XCTAssertTrue(true)
        }
    }
}

final class URLProtocolMock: URLProtocol {
    static var result: Result<(HTTPURLResponse, Data), Error> = .failure(ErrorDummy())
    
    final override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    final override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    final override func startLoading() {
        switch Self.result {
        case .success(let (response, data)):
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        case .failure(let error):
            client?.urlProtocol(self, didFailWithError: error)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    final override func stopLoading() { }
}
