//
//  FetchArchivalMeasurementsUseCase.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 21/05/2024.
//

import Foundation
import Alamofire

protocol FetchArchivalMeasurementsUseCaseProtocol: PaginationFetchingUseCaseProtocol, Sendable
where DomainModel == SensorMeasurement, Parameters == SensorArchivalMeasurementsListOptions {
    func fetchNextPage() async throws
    func refresh() async throws
    func getStream() async -> AsyncStream<PageStream>
    func setParameters(_ parameters: Parameters) async
    func getParameters() async -> Parameters
}

actor FetchArchivalMeasurementsUseCase: FetchArchivalMeasurementsUseCaseProtocol {
    
    // MARK: Type aliases
    
    typealias DomainModel = SensorMeasurement
    
    // MARK: Private properties
    
    private var page: Int = 0
    private var size: Int = 80
    private var continuation: AsyncStream<PageStream>.Continuation?
    private let sensor: Sensor
    private let calendar = Calendar.current
    private lazy var parameters: SensorArchivalMeasurementsListOptions = createDefaultsFetchOptions()
    
    private var giosApiV1Repository: GIOSApiV1RepositoryProtocol {
        Injected[\.giosApiV1Repository]
    }
    
    private var sensorMeasurementNetworkMapper: any SensorMeasurementNetworkMapperProtocol {
        Injected[\.sensorMeasurementsNetworkMapper]
    }
    
    // MARK: Lifecycle
    
    init(sensor: Sensor) {
        self.sensor = sensor
    }
    
    // MARK: Methods
    
    func fetchNextPage() async throws {
        try await fetchPage(page, size: size)
        page += 1
    }
    
    func refresh() async throws {
        page = 0
        try await fetchNextPage()
    }
    
    func getStream() async -> AsyncStream<PageStream> {
        AsyncStream<PageStream> { continuation in
            Task { [weak self] in
                await self?.setContinuation(continuation)
            }
        }
    }
    
    func setParameters(_ parameters: SensorArchivalMeasurementsListOptions) async {
        self.parameters = parameters
    }
    
    func getParameters() async -> SensorArchivalMeasurementsListOptions {
        parameters
    }
    
    // MARK: Private methods
    
    private func fetchPage(_ page: Int, size: Int) async throws {
        let endpoint = Endpoint.ArchivalMeasurements.get(
            sensorId: sensor.id,
            page: page,
            size: size,
            options: parameters
        )
        
        let response = try await giosApiV1Repository.fetch(
            mapper: sensorMeasurementNetworkMapper,
            endpoint: endpoint,
            mappingInputParameters: sensor.param
        )
        
        let areMorePages = page < max((response.totalPages - 1), 0)
        
        continuation?.yield((response.output, areMorePages))
    }
    
    private func setContinuation(_ continuation: AsyncStream<PageStream>.Continuation) {
        self.continuation = continuation
    }
    
    private func createDefaultsFetchOptions() -> SensorArchivalMeasurementsListOptions {
        let dateTo = Date()
        let dateFrom: Date
        
        if let date = calendar.date(byAdding: .day, value: -14, to: dateTo) {
            dateFrom = date
        } else {
            Logger.error("Creating default dateFrom failed!")
            dateFrom = dateTo
        }
        
        let dateSorting = SensorArchivalMeasurementsListOptions.Sorting.Date.descending
        
        return SensorArchivalMeasurementsListOptions(
            filters: .init(dateFrom: dateFrom, dateTo: dateTo),
            sorting: .init(date: dateSorting)
        )
    }
}
