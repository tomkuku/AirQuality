//
//  SensorsNetworkMapperSpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 18/06/2024.
//

import Foundation

@testable import AirQuality

final class SensorsNetworkMapperSpy: SensorsNetworkMapperProtocol, @unchecked Sendable {
    enum Event: Equatable, Hashable {
        case map(SensorNetworkModel, Param, [SensorMeasurement])
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case let (.map(lhsSensorNetworkModel, lhsParam, lhsMeasurements), .map(rhsSensorNetworkModel, rhsParam, rhsMeasurements)):
                
                return lhsSensorNetworkModel.id == rhsSensorNetworkModel.id &&
                lhsParam == rhsParam &&
                lhsMeasurements == rhsMeasurements
            }
        }
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .map(let sensorNetworkModel, _, _):
                hasher.combine(sensorNetworkModel.id)
            }
        }
    }
    
    var events: [Event] = []
    
    func map(
        _ input: SensorNetworkModel,
        using inputParameters: (param: Param, measurements: [SensorMeasurement])
    ) throws -> Sensor {
        events.append(.map(input, inputParameters.param, inputParameters.measurements))
        
        return Sensor(id: input.id, param: inputParameters.param, measurements: inputParameters.measurements)
    }
}
