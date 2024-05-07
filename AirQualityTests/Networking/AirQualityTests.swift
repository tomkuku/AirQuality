//
//  AirQualityTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 02/05/2024.
//

import XCTest
import Alamofire

@testable import AirQuality

final class AirQualityTests: XCTestCase {

    func testCreateUrl() throws {
        // Given
        
        // When
        let request = try EndpointFake().asURLRequest()
        
        // Then
        XCTAssertEqual(request.url, URL(string: "https://www.test.com/test?key1=value1"))
    }
}
