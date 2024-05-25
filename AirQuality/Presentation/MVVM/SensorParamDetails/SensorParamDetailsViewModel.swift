//
//  SensorParamDetailsViewModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 21/05/2024.
//

import Foundation

final class SensorParamDetailsViewModel: ObservableObject {
    
    var paramDescription: String {
        typealias Strings = Localizable.Param
        
        return switch sensor.param.type {
        case .c6h6:
            Strings.C6h6.description
        case .pm10:
            Strings.Pm10.description
        case .pm25:
            Strings.Pm25.description
        case .o3:
            Strings.O3.description
        case .no2:
            Strings.No2.description
        case .so2:
            Strings.So2.description
        case .co:
            Strings.Co.description
        }
    }
    
    private let sensor: Sensor
    
    init(sensor: Sensor) {
        self.sensor = sensor
    }
}
