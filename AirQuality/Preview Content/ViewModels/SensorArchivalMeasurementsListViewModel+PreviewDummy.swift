//
//  SensorArchiveMeasurementsListViewModel+PreviewDummy.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 21/05/2024.
//

import Foundation

extension SensorArchivalMeasurementsListViewModel {
    private struct GetArchivalMeasurementsUseCase: GetArchivalMeasurementsUseCaseProtocol {
        func getArchivalMeasurements(for sensorId: Int) async throws -> [SensorMeasurement] {
            let now = Date()
            let calendar = Calendar.current
            
            var measurements: [SensorMeasurement] = []
            
            for index in 0..<400 {
                guard let date = calendar.date(byAdding: .day, value: index, to: now) else {
                    continue
                }
                
                let value = Double.random(in: 0...150)
                
                let measuremnt = Foundation.Measurement<UnitConcentrationMass>.init(value: value, unit: .microgramsPerCubicMeter)
                
                measurements.append(SensorMeasurement(date: date, measurement: measuremnt))
            }
            
            return measurements
        }
    }
    
    nonisolated(unsafe) static let previewDummy = SensorArchivalMeasurementsListViewModel(
        sensor: .previewDummy(),
        getArchivalMeasurementsUseCase: GetArchivalMeasurementsUseCase()
    )
}
