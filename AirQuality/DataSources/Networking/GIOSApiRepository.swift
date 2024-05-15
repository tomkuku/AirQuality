//
//  GIOSApiRepository.swift
//
//
//  Created by Tomasz Kukułka on 30/04/2024.
//

import Foundation

protocol HasGIOSApiRepository {
    var giosApiRepository: GIOSApiRepositoryProtocol { get }
}

protocol GIOSApiRepositoryProtocol: Sendable {
    func fetch<T, R>(
        mapperType: T.Type,
        endpoint: R,
        contentContainerName: String
    ) async throws -> T.DomainModel where T: NetworkMapperProtocol, R: HTTPRequest
    
    func fetchSensors(for stationId: Int) async throws -> [Sensor]
}

final class GIOSApiRepository: GIOSApiRepositoryProtocol {
    
    // MARK: Private Properties
    
    private let decoder = JSONDecoder()
    private let httpDataSource: HTTPDataSourceProtocol
    private let paramsRepository: ParamsRepositoryProtocol
    
    // MARK: Lifecycle
    
    init(
        httpDataSource: HTTPDataSourceProtocol,
        paramsRepository: ParamsRepositoryProtocol
    ) {
        self.httpDataSource = httpDataSource
        self.paramsRepository = paramsRepository
    }
    
    // MARK: Methods
    
    func fetch<T, R>(
        mapperType: T.Type,
        endpoint: R,
        contentContainerName: String
    ) async throws -> T.DomainModel where T: NetworkMapperProtocol, R: HTTPRequest {
        let mapper = T()
        let request = try endpoint.asURLRequest()
        
        let data = try await httpDataSource.requestData(request)
        
        do {
            let container = try decoder.decode(GIOSApiV1Response.self, from: data)
            let networkModelObjects: T.DTOModel = try container.getValue(for: contentContainerName)
            return try mapper.map(networkModelObjects)
        } catch {
            throw error
        }
    }
    
    func fetchSensors(for stationId: Int) async throws -> [Sensor] {
        let mapper = SensorsNetworkMapper()
        let request = try Endpoint.Sensors.get(stationId).asURLRequest()
        
        let data = try await httpDataSource.requestData(request)
        
        let sensorNetworkModels = try decoder.decode([SensorNetworkModel].self, from: data)
        
        return try await withThrowingTaskGroup(of: (SensorNetworkModel, Param, [Measurement]).self) { group in
            sensorNetworkModels.forEach { sensorNetworkModel in
                guard let param = self.paramsRepository.getParam(withId: sensorNetworkModel.param.idParam) else { return }
                
                group.addTask {
                    let measurements = try await self.fetchMeasurementsForSensor(id: sensorNetworkModel.id)
                    return (sensorNetworkModel, param, measurements)
                }
            }
            
            var sensors = [Sensor]()
            
            for try await value in group {
                let sensor = try mapper.map(value)
                sensors.append(sensor)
            }
            
            return sensors
        }
    }
    
    // MARK: Private methods
    
    private func fetchMeasurementsForSensor(id sensorId: Int) async throws -> [Measurement] {
        try await fetch(
            mapperType: MeasurementsNetworkMapper.self,
            endpoint: Endpoint.Measurements.get(sensorId),
            contentContainerName: "Lista danych pomiarowych"
        )
    }
}
