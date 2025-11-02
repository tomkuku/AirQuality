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

enum GetSensorsUseCaseError: Error, LocalizedError {
    case noParamForSensor(Int)
    
    var errorDescription: String? {
        switch self {
        case .noParamForSensor(let paramId):
            "Param for sensor with id: \(paramId) not found!"
        }
    }
}

final class GetSensorsUseCase: GetSensorsUseCaseProtocol {
    var giosApiV1Repository: GIOSApiV1RepositoryProtocol {
        Injected[\.giosApiV1Repository]
    }
    
    var measurementsNetworkMapper: any SensorMeasurementNetworkMapperProtocol {
        Injected[\.sensorMeasurementsNetworkMapper]
    }
    
    var dtoSensorsNetworkMapper: any DTOSensorsNetworkMapperProtocol {
        Injected[\.dtoSensorsNetworkMapper]
    }
    
    func getSensors(for stationId: Int) async throws -> [Sensor] {
        try await withThrowingTaskGroup(
            of: (sensorId: Int, measurements: [SensorMeasurement], param: Param?)?.self
        ) { group in
            let dtoSensors = try await fetchSensors(for: stationId)
            
            for dtoSensor in dtoSensors {
                group.addTask { [weak self] in
                    guard let self else { return nil }
                    
                    let measurements = try await self.fetchMeasurements(for: dtoSensor.id)
                    let param = self.getParam(for: dtoSensor.paramId)
                    
                    return (dtoSensor.id, measurements, param)
                }
            }
            
            var sensors: [Sensor] = []
            
            for try await result in group.compactMap({ $0 }) {
                guard let param = result.param else {
                    Logger.info("Param for sensor: \(result.sensorId) not found!")
                    continue
                }
                
                let sensor = Sensor(id: result.sensorId, param: param, measurements: result.measurements)
                sensors.append(sensor)
            }
            
            return sensors
        }
    }
    
    // MARK: Private methods
    
    private func fetchSensors(for stationId: Int) async throws -> [DTO.Sensor] {
        try await giosApiV1Repository.fetch(
            mapper: dtoSensorsNetworkMapper,
            endpoint: Endpoint.Sensors.get(stationId),
            contentContainerName: .sensors
        )
    }
    
    private func fetchMeasurements(for sensorId: Int) async throws -> [SensorMeasurement] {
        try await giosApiV1Repository.fetch(
            mapper: measurementsNetworkMapper,
            endpoint: Endpoint.Measurements.get(sensorId),
            contentContainerName: .measurements
        )
    }
    
    private func getParam(for sensorParamId: Int) -> Param? {
        Param(id: sensorParamId)
    }
}
