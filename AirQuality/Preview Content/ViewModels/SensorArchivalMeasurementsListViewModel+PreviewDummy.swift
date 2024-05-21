//
//  SensorArchiveMeasurementsListViewModel+PreviewDummy.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 21/05/2024.
//

import Foundation

extension SensorArchivalMeasurementsListViewModel {
    private struct GetArchivalMeasurementsUseCase: GetArchivalMeasurementsUseCaseProtocol {
        func getArchivalMeasurements(for sensorId: Int) async throws -> [Measurement] {
            [
                Measurement(date: Date(), value: 12),
                Measurement(date: Date(), value: 24),
                Measurement(date: Date(), value: nil)
            ]
        }
    }
    
    nonisolated(unsafe) static let previewDummy = SensorArchivalMeasurementsListViewModel(
        sensor: .previewDummy(),
        getArchivalMeasurementsUseCase: GetArchivalMeasurementsUseCase()
    )
}
