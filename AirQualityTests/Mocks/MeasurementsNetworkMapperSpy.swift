//
//  MeasurementsNetworkMapperSpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 18/06/2024.
//

import Foundation

@testable import AirQuality

final class SensorMeasurementNetworkMapperSpy: SensorMeasurementNetworkMapperProtocol, @unchecked Sendable {
    enum Event: Equatable, Hashable {
        case map([MeasurementNetworkModel])
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case let (.map(lhsMeasurementNetworkModel), .map(rhsMeasurementNetworkModel)):
                return lhsMeasurementNetworkModel == rhsMeasurementNetworkModel
            }
        }
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .map(let measurementNetworkModel):
                let count = measurementNetworkModel.count
                let valuesSum = measurementNetworkModel.reduce(into: Double(), {
                    $0 += $1.value ?? 0
                })
                
                hasher.combine(Double(count) + valuesSum)
            }
        }
    }
    
    var events: [Event] = []
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }()
    
    func map(_ input: [MeasurementNetworkModel]) throws -> [SensorMeasurement] {
        events.append(.map(input))
        
        return try input.compactMap {
            guard let date = dateFormatter.date(from: $0.date) else {
                throw NSError(domain: "MeasurementsNetworkMapper", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Formatting date: \($0.date) failed!"
                ])
            }
            
            var measurement: Measurement<UnitConcentrationMass>?
            
            if let value = $0.value {
                measurement = .init(value: value, unit: .microgramsPerCubicMeter)
            }
                
            return SensorMeasurement(date: date, measurement: measurement)
        }
    }
}
