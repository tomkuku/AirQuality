//
//  FetchArchivalMeasurementsUseCasePreviewDummy.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 31/10/2025.
//

import Foundation

actor FetchArchivalMeasurementsUseCasePreviewDummy: FetchArchivalMeasurementsUseCaseProtocol {
    
    // MARK: Type aliases
    
    typealias DomainModel = SensorMeasurement
    
    // MARK: Private properties
    
    private var page = 0
    private let size = 30
    private var startDate = Date()
    private nonisolated(unsafe) var continuation: AsyncStream<PageStream>.Continuation?
    private var parameters = SensorArchivalMeasurementsListOptions(filters: .init(dateFrom: Date(), dateTo: Date()), sorting: .init(date: .ascending))
    
    // MARK: Protocols methods
    
    func fetchNextPage() async throws {
        try await Task.sleep(for: .seconds(1))
        
        generateMeasurements()
        page += 1
    }
    
    func refresh() async throws {
        page = 0
        generateMeasurements()
    }
    
    func getStream() async -> AsyncStream<PageStream> {
        page = 0
        startDate = Date()
        
        return AsyncStream<PageStream> { continuation in
            Task { [weak self] in
                self?.continuation = continuation
            }
        }
    }
    
    func setParameters(_ parameters: FetchArchivalMeasurementsUseCase.Parameters) async { }
    
    func getParameters() async -> SensorArchivalMeasurementsListOptions { parameters }
    
    // MARK: Private methods
    
    private func generateMeasurements() {
        let measurements = Array(0..<size)
            .map { _ in
                let date = Calendar.current.date(byAdding: .hour, value: -1, to: startDate)! // swiftlint:disable:this force_unwrapping
                let value = Double.random(in: 0...100)
                let measurement = Measurement(value: value, unit: UnitConcentrationMass.microgramsPerCubicMeter)
                self.startDate = date
                return SensorMeasurement(date: date, measurement: measurement)
            }
            .sorted {
                $0.date > $1.date
            }
        
        let areMorePages = page < 4
        
        print("Fetch page", page, "areMorePages", areMorePages)
        
        continuation?.yield((measurements, areMorePages))
    }
}
