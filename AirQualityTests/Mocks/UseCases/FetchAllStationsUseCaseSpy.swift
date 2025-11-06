//
//  FetchAllStationsUseCaseSpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 18/06/2024.
//

import XCTest

@testable import AirQuality

final class FetchAllStationsUseCaseSpy: FetchAllStationsUseCaseProtocol, @unchecked Sendable {
    enum Event: Equatable {
        case fetch
    }
    
    var events: [Event] = []
    
    var fetchStationsResult: Result<[Station], Error>?
    
    func fetch() async throws -> [Station] {
        events.append(.fetch)
        
        return try await withCheckedThrowingContinuation { continuation in
            guard let fetchStationsResult else {
                XCTFail("Unhandled fetchStationsResult")
                return
            }
            
            continuation.resume(with: fetchStationsResult)
        }
    }
}
