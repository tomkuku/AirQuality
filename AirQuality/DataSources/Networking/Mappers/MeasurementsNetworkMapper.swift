//
//  MeasurementsNetworkMapper.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 13/05/2024.
//

import Foundation

protocol HasSensorMeasurementNetworkMapper {
    var sensorMeasurementsNetworkMapper: any SensorMeasurementNetworkMapperProtocol { get }
}

protocol SensorMeasurementNetworkMapperProtocol: NetworkMapperProtocol
where DTOModel == [MeasurementNetworkModel], DomainModel == [SensorMeasurement] { }

final class SensorMeasurementNetworkMapper: SensorMeasurementNetworkMapperProtocol {
    @Injected(\.sensorMeasurementDataFormatter) private var sensorMeasurementDataFormatter
    
    func map(_ input: [MeasurementNetworkModel]) throws -> [SensorMeasurement] {
        let sensorMeasurementDataFormatter = sensorMeasurementDataFormatter
        
        return try input.compactMap {
            guard let date = sensorMeasurementDataFormatter.date(from: $0.date) else {
                throw NSError(domain: "MeasurementsNetworkMapper", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Formatting date: \($0.date) failed!"
                ])
            }
            
            var measuremnt: Foundation.Measurement<UnitConcentrationMass>?
            
            if let value = $0.value {
                measuremnt = .init(value: value, unit: .microgramsPerCubicMeter)
            }
            
            return SensorMeasurement(date: date, measurement: measuremnt)
        }
    }
}
