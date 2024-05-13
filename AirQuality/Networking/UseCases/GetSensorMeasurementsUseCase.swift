//
//  GetSensorMeasurementsUseCase.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 13/05/2024.
//

import Foundation

protocol GetSensorMeasurementsUseCaseProtocol {
    func getMeasurements(for sensorId: Int) async throws -> [AirQuality.Measurement]
}

final class GetSensorMeasurementsUseCase: GetSensorMeasurementsUseCaseProtocol {
    @Injected(\.giosApiRepository) private var giosApiRepository
    
    func getMeasurements(for sensorId: Int) async throws -> [AirQuality.Measurement] {
        try await giosApiRepository.fetch(
            mapperType: MeasurementsNetworkMapper.self,
            endpoint: Endpoint.Measurements.get(sensorId),
            contentContainerName: "Lista danych pomiarowych"
        )
    }
}
