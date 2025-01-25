//
//  GetSensorsUseCase.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import Foundation
import Alamofire

protocol HasGetSensorsUseCase {
    var getSensorsUseCase: GetSensorsUseCaseProtocol { get }
}

protocol GetSensorsUseCaseProtocol: Sendable {
    func getSensors(for stationId: Int) async throws -> [Sensor]
}

final class GetSensorsUseCase: GetSensorsUseCaseProtocol {
    func getSensors(for stationId: Int) async throws -> [Sensor] {
        try await Injected[\.giosApiRepository].fetchSensors(for: stationId)
    }
}
