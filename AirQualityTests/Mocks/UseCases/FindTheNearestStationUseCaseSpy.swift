//
//  FindTheNearestStationUseCaseSpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 18/06/2024.
//

import XCTest

@testable import AirQuality

final class FindTheNearestStationUseCaseSpy: FindTheNearestStationUseCaseProtocol, @unchecked Sendable {
    enum Event: Equatable {
        case find
    }
    
    var events: [Event] = []
    
    var findStationsResult: Result<(station: Station, distance: Double), Error>?
    
    func find() async throws -> (station: Station, distance: Double)? {
        events.append(.find)
        
        return try await withCheckedThrowingContinuation { continuation in
            guard let findStationsResult else {
                XCTFail("Unhandled fetchStationsResult")
                return
            }
            
            continuation.resume(with: findStationsResult)
        }
    }
}
