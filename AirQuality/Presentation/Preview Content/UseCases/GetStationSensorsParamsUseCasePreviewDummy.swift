//
//  GetStationSensorsParamsUseCasePreviewDummy.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 02/07/2024.
//

import Foundation

final class GetStationSensorsParamsUseCasePreviewDummy: GetStationSensorsParamsUseCaseProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var getParamsResult: [Param]?
    
    func get(_ stationId: Int) async throws -> [Param] {
        try await Task.sleep(for: .seconds(1))
        
        return try await withCheckedThrowingContinuation {
            switch Self.getParamsResult {
            case .some(let params):
                $0.resume(returning: params)
            case .none:
                break
            }
        }
    }
}
