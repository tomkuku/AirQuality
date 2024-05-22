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
            let now = Date()
            let calendar = Calendar.current
            
            var measurements: [Measurement] = []
            
            for index in 0..<400 {
                guard let date = calendar.date(byAdding: .day, value: index, to: now) else {
                    continue
                }
                
                let value = Double.random(in: 0...150)
                
                measurements.append(Measurement(date: date, value: value))
            }
            
            return measurements
        }
    }
    
    nonisolated(unsafe) static let previewDummy = SensorArchivalMeasurementsListViewModel(
        sensor: .previewDummy(),
        getArchivalMeasurementsUseCase: GetArchivalMeasurementsUseCase()
    )
}
