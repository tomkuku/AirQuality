//
//  AddObservedStationUseCaseSpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 18/06/2024.
//

import XCTest

@testable import AirQuality

final class AddObservedStationUseCaseSpy: AddObservedStationUseCaseProtocol, @unchecked Sendable {
    enum Event: Equatable {
        case add(Station)
    }
    
    var events: [Event] = []
    
    var expectation: XCTestExpectation?
    var addStationThrowError: Error?
    
    func add(station: Station) async throws {
        events.append(.add(station))
        
        if let addStationThrowError {
            throw addStationThrowError
        } else {
            expectation?.fulfill()
        }
    }
}
