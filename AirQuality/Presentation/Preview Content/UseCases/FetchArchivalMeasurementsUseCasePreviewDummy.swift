//
//  FetchArchivalMeasurementsUseCasePreviewDummy.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 31/10/2025.
//

import Foundation

actor FetchArchivalMeasurementsUseCasePreviewDummy: FetchArchivalMeasurementsUseCaseProtocol {
    
    // MARK: Properties
    
    var parameters = FetchArchivalMeasurementsUseCase.Parameters(dateFrom: "", dateTo: "", sort: "", sensorId: 0)
    
    // MARK: Private properties
    
    private var page = 0
    private let size = 30
    private var startDate = Date()
    private nonisolated(unsafe) var continuation: AsyncStream<[SensorMeasurement]>.Continuation?
    
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
    
    func getStream() async -> AsyncStream<[SensorMeasurement]> {
        page = 0
        startDate = Date()
        
        return AsyncStream<[SensorMeasurement]> { continuation in
            Task { [weak self] in
                self?.continuation = continuation
            }
        }
    }
    
    func setParameters(_ parameters: FetchArchivalMeasurementsUseCase.Parameters) async { }
    
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
        
        page += 1
        
        continuation?.yield(measurements)
    }
}
