//
//  GetSensorMeasurementsUseCaseSpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 13/05/2024.
//

import XCTest

@testable import AirQuality

@globalActor actor TestActor: GlobalActor {
    static var shared = TestActor()
}

final class GetSensorMeasurementsUseCaseSpy: GetSensorMeasurementsUseCaseProtocol {
    enum Event: Equatable, Hashable {
        case getMeasurements(Int)
    }
    
    private(set) var events: [Event] = []
    
    var fetchResultBlock: ((_ sensorId: Int) -> Result<[AirQuality.Measurement], Error>)?
    
    @TestActor
    func getMeasurements(for sensorId: Int) async throws -> [AirQuality.Measurement] {
        events.append(.getMeasurements(sensorId))
        
        return try await withCheckedThrowingContinuation { continuation in
            guard let fetchResult = fetchResultBlock?(sensorId) else {
                XCTFail("Result should have been set!")
                return
            }
            
            switch fetchResult {
            case .success(let sensors):
                continuation.resume(returning: sensors)
            case .failure(let error):
                continuation.resume(throwing: error)
            }
        }
    }
}
