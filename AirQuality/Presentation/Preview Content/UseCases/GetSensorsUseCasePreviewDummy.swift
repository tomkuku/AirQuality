//
//  GetSensorsUseCasePreviewDummy.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 21/06/2024.
//

import Foundation

final class GetSensorsUseCasePreviewDummy: GetSensorsUseCaseProtocol {
    nonisolated(unsafe) static var fetchReturnValue: [Sensor] = []
    
    func getSensors(for stationId: Int) async throws -> [Sensor] {
        Self.fetchReturnValue
    }
}
