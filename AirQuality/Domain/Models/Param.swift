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

struct Param: Sendable, Equatable, Hashable {
    let type: ParamType
    let code: String
    let formula: String
    let quota: Double
    let unit: String
    let indexLevels: IndexLevels
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type.rawValue)
    }
    
    func getAqi(for value: Double?) -> AQI {
        switch Int(value ?? -1) {
        case 0...indexLevels.good:
            .good
        case indexLevels.good...indexLevels.moderate:
            .moderate
        case indexLevels.moderate...indexLevels.unhealthyForSensitiveGroup:
            .unhealthyForSensitiveGroup
        case indexLevels.unhealthyForSensitiveGroup...indexLevels.unhealthy:
            .unhealthy
        case indexLevels.unhealthy...indexLevels.veryUnhealthy:
            .veryUnhealthy
        case indexLevels.veryUnhealthy...:
            .hazardus
        default:
            .undefined
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
    
    init?(id: Int) {
        switch id {
        case ParamType.pm10.rawValue:
            self = .pm10
        case ParamType.pm25.rawValue:
            self = .pm25
        case ParamType.c6h6.rawValue:
            self = .c6h6
        case ParamType.o3.rawValue:
            self = .o3
        case ParamType.no2.rawValue:
            self = .no2
        case ParamType.so2.rawValue:
            self = .so2
        case ParamType.co.rawValue:
            self = .co
        default:
            return nil
        }
    }
    
    init(
        type: ParamType,
        code: String,
        formula: String,
        quota: Double,
        unit: String,
        indexLevels: IndexLevels
    ) {
        self.type = type
        self.code = code
        self.formula = formula
        self.quota = quota
        self.unit = unit
        self.indexLevels = indexLevels
    }
}

extension Param {
    struct IndexLevels: Sendable, Equatable {
        let good: Int
        let moderate: Int
        let unhealthyForSensitiveGroup: Int
        let unhealthy: Int
        let veryUnhealthy: Int
    }
}
