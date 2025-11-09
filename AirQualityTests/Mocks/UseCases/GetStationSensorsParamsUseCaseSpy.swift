//
//  GetStationSensorsParamsUseCaseSpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 03/07/2024.
//

import XCTest

@testable import AirQuality

final class GetStationSensorsParamsUseCaseSpy: GetStationSensorsParamsUseCaseProtocol, @unchecked Sendable {
    enum Event: Equatable {
        case get(Int)
    }
    
    var events: [Event] = []
    
    var getResult: Result<[Param], Error>?
    
    func get(_ stationId: Int) async throws -> [Param] {
        events.append(.get(stationId))
        
        return try await withCheckedThrowingContinuation { continuation in
            guard let getResult else {
                XCTFail("Unhandled getResult")
                return
            }
            
            continuation.resume(with: getResult)
        }
    }
}
