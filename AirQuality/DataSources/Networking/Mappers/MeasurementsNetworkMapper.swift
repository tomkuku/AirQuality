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
where DTOModel == [MeasurementNetworkModel], DomainModel == [SensorMeasurement], InputParameters == (Param) { }

final class SensorMeasurementNetworkMapper: SensorMeasurementNetworkMapperProtocol {
    func map(_ input: [MeasurementNetworkModel], using inputParameters: (Param)) throws -> [SensorMeasurement] {
        let sensorMeasurementDataFormatter = Injected[\.sensorMeasurementDataFormatter]
        
        return try input.compactMap {
            guard let date = sensorMeasurementDataFormatter.date(from: $0.date) else {
                throw NSError(domain: "MeasurementsNetworkMapper", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Formatting date: \($0.date) failed!"
                ])
            }
            
            var measurement: Foundation.Measurement<UnitConcentrationMass>?
            
            if let value = $0.value {
                let calculatedValue = value / inputParameters.factor
                var unit = UnitConcentrationMass.microgramsPerCubicMeter
                
                if inputParameters.unit == UnitConcentrationMass.milligramsPerCubicMeter.symbol {
                    unit = .milligramsPerCubicMeter
                }
                
                measurement = .init(value: calculatedValue, unit: unit)
            }
            
            return SensorMeasurement(date: date, measurement: measurement)
        }
    }
}
