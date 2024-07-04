//
//  GetSensorsUseCaseSpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 13/05/2024.
//

import XCTest

@testable import AirQuality

final class GetSensorsUseCaseSpy: GetSensorsUseCaseProtocol, @unchecked Sendable {
    enum Event: Equatable {
        case getSensors(Int)
    }
    
    private(set) var events: [Event] = []
    
    var getSensorsResultClosure: (() -> Result<[Sensor], Error>)?
    
    func getSensors(for stationId: Int) async throws -> [Sensor] {
        events.append(.getSensors(stationId))
        
        return try await withCheckedThrowingContinuation { continuation in
            switch getSensorsResultClosure?() {
            case .success(let sensors):
                continuation.resume(returning: sensors)
            case .failure(let error):
                continuation.resume(throwing: error)
            case .none:
                fatalError("Result should have been set!")
            }
        }
    }
}
