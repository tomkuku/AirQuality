//
//  GetArchivalMeasurementsUseCase.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 21/05/2024.
//

import Foundation
import Alamofire

protocol GetArchivalMeasurementsUseCaseProtocol: Sendable {
    func getArchivalMeasurements(for sensorId: Int) async throws -> [Measurement]
}

final class GetArchivalMeasurementsUseCase: GetArchivalMeasurementsUseCaseProtocol, @unchecked Sendable {
    @Injected(\.giosApiV1Repository) private var giosApiV1Repository
    
    private let measurementsNetworkMapper: any MeasurementsNetworkMapperProtocol
    
    init(measurementsNetworkMapper: any MeasurementsNetworkMapperProtocol) {
        self.measurementsNetworkMapper = measurementsNetworkMapper
    }
    
    func getArchivalMeasurements(for sensorId: Int) async throws -> [Measurement] {
        try await giosApiV1Repository.fetch(
            mapper: measurementsNetworkMapper,
            endpoint: Endpoint.ArchivalMeasurements.get(sensorId),
            contentContainerName: "Lista archiwalnych wyników pomiarów"
        )
    }
}
