//
//  GIOSApiRepository.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 25/05/2024.
//

import Foundation
import Combine
import Alamofire

protocol HasGIOSApiRepository {
    var giosApiRepository: GIOSApiRepositoryProtocol { get }
}

enum SourceType {
    // Checks if value of requested resource is cached. If it's cached, it will return this value. If it is not cached, fetch value remotly, caches it and then returns value.
    case cacheIfPossible
    // Fetch value remotly.
    case remote
}

protocol GIOSApiRepositoryProtocol {
    func fetch<T>(
        mapper: T,
        endpoint: any HTTPRequest,
        source: SourceType
    ) async throws -> T.DomainModel where T: NetworkMapperProtocol
    
    func fetchSensors(for stationId: Int) async throws -> [Sensor]
}

extension GIOSApiRepositoryProtocol {
    func fetch<T>(
        mapper: T,
        endpoint: any HTTPRequest,
        source: SourceType = .remote
    ) async throws -> T.DomainModel where T: NetworkMapperProtocol {
        try await self.fetch(mapper: mapper, endpoint: endpoint, source: source)
    }
}

actor GIOSApiRepository: GIOSApiRepositoryProtocol {
    
    // MARK: Private Properties
    
    @Injected(\.cacheDataSource) private var cacheDataSource
    @Injected(\.giosApiV1Repository) private var giosApiV1Repository
    @Injected(\.sensorsNetworkMapper) private var sensorsNetworkMapper
    @Injected(\.sensorMeasurementsNetworkMapper) private var sensorMeasurementsNetworkMapper
    
    private let httpDataSource: HTTPDataSourceProtocol
    private var cancellables = Set<AnyCancellable>()
    private let jsonDecoder: JSONDecoder
    
    // MARK: Lifecycle
    
    init(
        httpDataSource: HTTPDataSourceProtocol,
        decoder: JSONDecoder = .init()
    ) {
        self.httpDataSource = httpDataSource
        self.jsonDecoder = decoder
    }
    
    // MARK: Methods
    
    func fetch<T>(
        mapper: T,
        endpoint: any HTTPRequest,
        source: SourceType
    ) async throws -> T.DomainModel where T: NetworkMapperProtocol {
        let url = endpoint.urlRequest?.url
        
        if source == .cacheIfPossible, let value: T.DomainModel = await cacheDataSource.get(url: url) {
            return value
        }
        
        let netwokModel: T.DTOModel = try await handleFetch(endpoint: endpoint)
        let domainModel = try mapper.map(netwokModel)
        
        if source == .cacheIfPossible {
            await cacheDataSource.set(url: url, value: domainModel)
        }
        
        return domainModel
    }
    
    func fetchSensors(for stationId: Int) async throws -> [Sensor] {
        try await withThrowingTaskGroup(of: (SensorNetworkModel, Param, [SensorMeasurement])?.self) { [weak self] group in
            guard let self else {
                Logger.error("\(String(describing: Self.self)) is nil")
                return []
            }
            
            try await handleFetchSensors(for: stationId).forEach { sensorNetworkModel in
                group.addTask {
                    guard let param = Param(id: sensorNetworkModel.param.idParam) else { return nil }
                    let measurements = try await self.handleFetchMeasurements(forSensorId: sensorNetworkModel.id)
                    return (sensorNetworkModel, param, measurements)
                }
            }
            
            var sensors = [Sensor]()
            
            for try await value in group {
                guard let value else {
                    Logger.error("Sensor value is nil!")
                    continue
                }
                
                let sensor = try await self.sensorsNetworkMapper.map(value)
                sensors.append(sensor)
            }
            
            return sensors
        }
    }
    
    // MARK: Private methods
    
    private func handleFetchMeasurements(forSensorId sensorId: Int) async throws -> [SensorMeasurement] {
        try await giosApiV1Repository.fetch(
            mapper: sensorMeasurementsNetworkMapper,
            endpoint: Endpoint.Measurements.get(sensorId),
            contentContainerName: "Lista danych pomiarowych"
        )
    }
    
    private func handleFetchSensors(for stationId: Int) async throws -> [SensorNetworkModel] {
        try await handleFetch(endpoint: Endpoint.Sensors.get(stationId))
    }
    
    private func handleFetch<T>(
        endpoint: any HTTPRequest
    ) async throws -> T where T: Decodable {
        let data = try await httpDataSource.requestData(endpoint)
        return try jsonDecoder.decode(T.self, from: data)
    }
}
