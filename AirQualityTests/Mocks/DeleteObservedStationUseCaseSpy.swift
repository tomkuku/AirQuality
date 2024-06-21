//
//  DeleteObservedStationUseCaseSpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 18/06/2024.
//

import XCTest

@testable import AirQuality

final class DeleteObservedStationUseCaseSpy: DeleteObservedStationUseCaseProtocol, @unchecked Sendable {
    enum Event: Equatable {
        case delete(Station)
    }
    
    var events: [Event] = []
    
    var expectation: XCTestExpectation?
    var deleteStationThrowError: Error?
    
    func delete(station: Station) async throws {
        events.append(.delete(station))
        
        if let deleteStationThrowError {
            throw deleteStationThrowError
        } else {
            expectation?.fulfill()
        }
    }
}
