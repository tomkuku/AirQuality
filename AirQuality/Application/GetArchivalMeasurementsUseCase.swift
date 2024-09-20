//
//  GetArchivalMeasurementsUseCase.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 21/05/2024.
//

import Foundation
import Alamofire

protocol GetArchivalMeasurementsUseCaseProtocol: Sendable {
    func getArchivalMeasurements(for sensorId: Int) async throws -> [SensorMeasurement]
}

final class GetArchivalMeasurementsUseCase: GetArchivalMeasurementsUseCaseProtocol {
    @Injected(\.giosApiV1Repository) private var giosApiV1Repository
    
    private let sensorMeasurementNetworkMapper: any SensorMeasurementNetworkMapperProtocol
    
    init(sensorMeasurementNetworkMapper: any SensorMeasurementNetworkMapperProtocol) {
        self.sensorMeasurementNetworkMapper = sensorMeasurementNetworkMapper
    }
    
    func getArchivalMeasurements(for sensorId: Int) async throws -> [SensorMeasurement] {
        try await giosApiV1Repository.fetch(
            mapper: sensorMeasurementNetworkMapper,
            endpoint: Endpoint.ArchivalMeasurements.get(sensorId),
            contentContainerName: "Lista archiwalnych wyników pomiarów"
        )
    }
}
