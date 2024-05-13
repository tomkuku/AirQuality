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
    @Injected(\.giosApiRepository) private var giosApiRepository
    
    func getSensors(for stationId: Int) async throws -> [Sensor] {
        try await giosApiRepository.fetch(
            mapperType: SensorsNetworkMapper.self,
            endpoint: Endpoint.Sensors.get(stationId),
            contentContainerName: "Lista stanowisk pomiarowych dla podanej stacji"
        )
    }
}
