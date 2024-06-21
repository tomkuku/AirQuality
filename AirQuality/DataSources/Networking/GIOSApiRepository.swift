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
    @Injected(\.paramsRepository) private var paramsRepository
    @Injected(\.sensorsNetworkMapper) private var sensorsNetworkMapper
    @Injected(\.measurementsNetworkMapper) private var measurementsNetworkMapper
    
    private let httpDataSource: HTTPDataSourceProtocol
    private var cancellables = Set<AnyCancellable>()
    private let decoder: JSONDecoder
    
    // MARK: Lifecycle
    
    init(
        httpDataSource: HTTPDataSourceProtocol,
        decoder: JSONDecoder = .init()
    ) {
        self.httpDataSource = httpDataSource
        self.decoder = decoder
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
        try await withThrowingTaskGroup(of: (SensorNetworkModel, Param, [Measurement])?.self) { [weak self] group in
            guard let self else {
                Logger.error("\(String(describing: Self.self)) is nil")
                return []
            }
            
            try await handleFetchSensors(for: stationId).forEach { sensorNetworkModel in
                group.addTask {
                    guard let param = await self.paramsRepository.getParam(withId: sensorNetworkModel.param.idParam) else { return nil }
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
    
    private func handleFetchMeasurements(forSensorId sensorId: Int) async throws -> [Measurement] {
        try await giosApiV1Repository.fetch(
            mapper: measurementsNetworkMapper,
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
        /// This code must be a closure because it must be called after continuation has been initialised.
        /// Otherwise, `requestData` may return data before withCheckedThrowingContinuation will be executed.
        let requestClosure: (@Sendable (isolated GIOSApiRepository, CheckedContinuation<T, Error>) -> ()) = { actorSelf, continuation in
            let cancellable = actorSelf
                .httpDataSource
                .requestData(endpoint)
                .tryCompactMap {
                    try actorSelf.decoder.decode(T.self, from: $0)
                }
                .sink {
                    guard case .failure(let error) = $0 else { return }
                    
                    continuation.resume(throwing: error)
                } receiveValue: {
                    continuation.resume(returning: $0)
                }
            
            actorSelf.cancellables.insert(cancellable)
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            Task { [weak self] in
                guard let self else { return }
                
                await requestClosure(self, continuation)
            }
        }
    }
}
