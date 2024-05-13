//
//  GetSensorsUseCaseSpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 13/05/2024.
//

import XCTest

@testable import AirQuality

final class GetSensorsUseCaseSpy: GetSensorsUseCaseProtocol {
    enum Event: Equatable {
        case getSensors(Int)
    }
    
    private(set) var events: [Event] = []
    
    var fetchResult: Result<[Sensor], Error>?
    
    @TestActor
    func getSensors(for stationId: Int) async throws -> [Sensor] {
        events.append(.getSensors(stationId))
        
        return try await withCheckedThrowingContinuation { continuation in
            switch fetchResult {
            case .success(let sensors):
                continuation.resume(returning: sensors)
            case .failure(let error):
                continuation.resume(throwing: error)
            case .none:
                XCTFail("Result should have been set!")
            }
        }
    }
}
