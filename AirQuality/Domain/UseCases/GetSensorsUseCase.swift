//
//  GetSensorsUseCase.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import Foundation
import Alamofire

protocol GetSensorsUseCaseProtocol {
    func getSensors(for stationId: Int) async throws -> [Sensor]
}

final class GetSensorsUseCase: GetSensorsUseCaseProtocol {
    @Injected(\.giosApiV1Repository) private var giosApiV1Repository
    
    func getSensors(for stationId: Int) async throws -> [Sensor] {
        try await giosApiV1Repository.fetchSensors(for: stationId)
    }
}
