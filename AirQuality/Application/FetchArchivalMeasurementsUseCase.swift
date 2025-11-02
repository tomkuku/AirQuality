//
//  FetchArchivalMeasurementsUseCase.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 21/05/2024.
//

import Foundation
import Alamofire

protocol HasFetchArchivalMeasurementsUseCase {
    var fetchArchivalMeasurementsUseCase: any FetchArchivalMeasurementsUseCaseProtocol { get }
}

protocol FetchArchivalMeasurementsUseCaseProtocol: PaginationFetchingUseCaseProtocol, Sendable
where DomainModel == SensorMeasurement, Parameters == FetchArchivalMeasurementsUseCase.Parameters {
    func fetchNextPage() async throws
    func refresh() async throws
    func getStream() async -> AsyncStream<[SensorMeasurement]>
    func setParameters(_ parameters: Parameters) async
}

actor FetchArchivalMeasurementsUseCase: FetchArchivalMeasurementsUseCaseProtocol {
    
    struct Parameters: PaginationFetchingUseCaseParameters {
        let dateFrom: String
        let dateTo: String
        let sort: String
        let sensorId: Int
    }
    
    // MARK: Properties
    
    var parameters = Parameters(dateFrom: "", dateTo: "", sort: "", sensorId: 1)
    
    // MARK: Private properties
    
    private var page: Int = 0
    private var size: Int = 100
    private var continuation: AsyncStream<[SensorMeasurement]>.Continuation?
    
    private var giosApiV1Repository: GIOSApiV1RepositoryProtocol {
        Injected[\.giosApiV1Repository]
    }
    
    private var sensorMeasurementNetworkMapper: any SensorMeasurementNetworkMapperProtocol {
        Injected[\.sensorMeasurementsNetworkMapper]
    }
    
    // MARK: Lifecycle
    
    init() { }
    
    // MARK: Methods
    
    func fetchNextPage() async throws {
        try await fetchPage(page: 0, size: size)
        page += 1
    }
    
    func refresh() async throws {
        page = 0
        try await fetchNextPage()
    }
    
    func getStream() async -> AsyncStream<[SensorMeasurement]> {
        AsyncStream<[SensorMeasurement]> { [weak self] continuation in
            Task { [weak self] in
                await self?.setContinuation(continuation)
            }
        }
    }
    
    func setParameters(_ parameters: Parameters) async {
        self.parameters = parameters
    }
    
    // MARK: Private methods
    
    private func fetchPage(page: Int, size: Int) async throws {
        let endpoint = Endpoint.ArchivalMeasurements.get(
            sensorId: parameters.sensorId,
            page: page,
            size: size,
            dateFrom: parameters.dateFrom,
            dateTo: parameters.dateTo,
            sort: parameters.sort
        )
        
        let measurements = try await giosApiV1Repository.fetch(
            mapper: sensorMeasurementNetworkMapper,
            endpoint: endpoint,
            contentContainerName: .archivalMeasurements
        )
        
        continuation?.yield(measurements)
    }
    
    private func setContinuation(_ continuation: AsyncStream<[SensorMeasurement]>.Continuation) {
        self.continuation = continuation
    }
}
