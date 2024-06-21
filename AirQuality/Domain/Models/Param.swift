//
//  Param.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 14/05/2024.
//

import Foundation

enum ParamType: Int, Equatable {
    case c6h6 = 10
    case pm10 = 3
    case pm25 = 69
    case o3 = 5
    case no2 = 6
    case so2 = 1
    case co = 8
}

struct Param: Sendable, Equatable {
    let type: ParamType
    let code: String
    let formula: String
    let quota: Double
    let indexLevels: IndexLevels
    
    func getAqi(for value: Double?) -> AQI {
        switch Int(value ?? -1) {
        case 0...indexLevels.veryGood:
            return .good
        case indexLevels.veryGood...indexLevels.good:
            return .moderate
        case indexLevels.good...indexLevels.moderate:
            return .unhealthyForSensitiveGroup
        case indexLevels.moderate...indexLevels.sufficient:
            return .unhealthy
        case indexLevels.sufficient...indexLevels.bad:
            return .veryUnhealthy
        case indexLevels.bad...:
            return .hazardus
        default:
            return .undefined
        }
    }
    
    var name: String {
        typealias Strings = Localizable.Param
        
        return switch type {
        case .c6h6:
            Strings.C6h6.name
        case .pm10:
            Strings.Pm10.name
        case .pm25:
            Strings.Pm25.name
        case .o3:
            Strings.O3.name
        case .no2:
            Strings.No2.name
        case .so2:
            Strings.So2.name
        case .co:
            Strings.Co.name
        }
    }
}

extension Param {
    struct IndexLevels: Sendable, Equatable {
        let veryGood: Int
        let good: Int
        let moderate: Int
        let sufficient: Int
        let bad: Int
    }
}
