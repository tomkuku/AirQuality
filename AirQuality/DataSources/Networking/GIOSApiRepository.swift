//
//  GIOSApiRepository.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 25/05/2024.
//

import Foundation

protocol HasGIOSApiRepository {
    var giosApiRepository: GIOSApiRepositoryProtocol { get }
}

enum SourceType {
    // Checks if value of requested resource is cached. If it's cached, it will return this value. If it is not cached, fetch value remotly, caches it and then returns value.
    case cacheIfPossible
    // Fetch value remotly.
    case remote
}

protocol GIOSApiRepositoryProtocol: Sendable {
    func fetch<T, R>(
        mapper: T,
        endpoint: R,
        source: SourceType
    ) async throws -> T.DomainModel where T: NetworkMapperProtocol, R: HTTPRequest
    
    func fetchSensors(for stationId: Int) async throws -> [Sensor]
}

extension GIOSApiRepositoryProtocol {
    func fetch<T, R>(
        mapper: T,
        endpoint: R,
        source: SourceType = .remote
    ) async throws -> T.DomainModel where T: NetworkMapperProtocol, R: HTTPRequest {
        try await self.fetch(mapper: mapper, endpoint: endpoint, source: source)
    }
}

final class GIOSApiRepository: GIOSApiRepositoryProtocol, Sendable {
    
    // MARK: Private Properties
    
    @Injected(\.cacheDataSource) private var cacheDataSource
    
    private let decoder = JSONDecoder()
    private let httpDataSource: HTTPDataSourceProtocol
    private let giosV1Repository: GIOSApiV1RepositoryProtocol
    private let paramsRepository: ParamsRepositoryProtocol
    private let sensorsNetworkMapper: any SensorsNetworkMapperProtocol
    private let measurementsNetworkMapper: any MeasurementsNetworkMapperProtocol
    
    // MARK: Lifecycle
    
    init(
        httpDataSource: HTTPDataSourceProtocol,
        paramsRepository: ParamsRepositoryProtocol,
        giosV1Repository: GIOSApiV1RepositoryProtocol,
        sensorsNetworkMapper: any SensorsNetworkMapperProtocol,
        measurementsNetworkMapper: any MeasurementsNetworkMapperProtocol
    ) {
        self.httpDataSource = httpDataSource
        self.paramsRepository = paramsRepository
        self.giosV1Repository = giosV1Repository
        self.sensorsNetworkMapper = sensorsNetworkMapper
        self.measurementsNetworkMapper = measurementsNetworkMapper
    }
    
    // MARK: Methods
    
    func fetch<T, R>(
        mapper: T,
        endpoint: R,
        source: SourceType
    ) async throws -> T.DomainModel where T: NetworkMapperProtocol, R: HTTPRequest {
        switch source {
        case .cacheIfPossible:
            let url = endpoint.urlRequest?.url
            
            if source == .cacheIfPossible, let value: T.DomainModel = await cacheDataSource.get(url: url) {
                return value
            }
            
            let value = try await handleFetchRemote(mapper: mapper, endpoint: endpoint)
            
            await cacheDataSource.set(url: url, value: value)
            
            return value
        case .remote:
            return try await handleFetchRemote(mapper: mapper, endpoint: endpoint)
        }
    }
    
    func fetchSensors(for stationId: Int) async throws -> [Sensor] {
        let sensorNetworkModels = try await handleFetchSensors(for: stationId)
        
        return try await withThrowingTaskGroup(of: (SensorNetworkModel, Param, [Measurement]).self) { [weak self] group in
            guard let self else {
                Logger.error("\(String(describing: Self.self)) is nil")
                return []
            }
            
            sensorNetworkModels.forEach { sensorNetworkModel in
                guard let param = self.paramsRepository.getParam(withId: sensorNetworkModel.param.idParam) else { return }
                
                group.addTask {
                    let measurements = try await self.handleFetchMeasurements(forSensorId: sensorNetworkModel.id)
                    return (sensorNetworkModel, param, measurements)
                }
            }
            
            var sensors = [Sensor]()
            
            for try await value in group {
                let sensor = try sensorsNetworkMapper.map(value)
                sensors.append(sensor)
            }
            
            return sensors
        }
    }
    
    // MARK: Private methods
    
    private func handleFetchMeasurements(forSensorId sensorId: Int) async throws -> [Measurement] {
        try await giosV1Repository.fetch(
            mapper: measurementsNetworkMapper,
            endpoint: Endpoint.Measurements.get(sensorId),
            contentContainerName: "Lista danych pomiarowych"
        )
    }
    
    private func handleFetchSensors(for stationId: Int) async throws -> [SensorNetworkModel] {
        let request = try Endpoint.Sensors.get(stationId).asURLRequest()
        let data = try await httpDataSource.requestData(request)
        
        return try decoder.decode([SensorNetworkModel].self, from: data)
    }
    
    private func handleFetchRemote<T, R>(
        mapper: T,
        endpoint: R
    ) async throws -> T.DomainModel where T: NetworkMapperProtocol, R: HTTPRequest {
        let request = try endpoint.asURLRequest()
        
        let data = try await httpDataSource.requestData(request)
        
        do {
            let dto = try decoder.decode(T.DTOModel.self, from: data)
            return try mapper.map(dto)
        } catch {
            throw error
        }
    }
}
