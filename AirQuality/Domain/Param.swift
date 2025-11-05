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
    case no2 = 16
    case so2 = 1
    case co = 8
}

struct Param: Sendable, Equatable, Hashable {
    let type: ParamType
    let code: String
    let formula: String
    let formulaNumbersInBottomBaseline: Bool
    let quota: Double
    let unit: String
    let factor: Double
    let indexLevelTresholds: IndexLevels.Tresholds
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type.rawValue)
    }
    
    func getAqi(for value: Double?) -> AQI {
        switch Int(value ?? -1) {
        case 0...indexLevelTresholds.good:
            .good
        case indexLevelTresholds.good...indexLevelTresholds.moderate:
            .moderate
        case indexLevelTresholds.moderate...indexLevelTresholds.unhealthyForSensitiveGroup:
            .unhealthyForSensitiveGroup
        case indexLevelTresholds.unhealthyForSensitiveGroup...indexLevelTresholds.unhealthy:
            .unhealthy
        case indexLevelTresholds.unhealthy...indexLevelTresholds.veryUnhealthy:
            .veryUnhealthy
        case indexLevelTresholds.veryUnhealthy...:
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
            Logger.error("No param with id: \(id)")
            return nil
        }
    }
    
    init(
        type: ParamType,
        code: String,
        formula: String,
        formulaNumbersInBottomBaseline: Bool,
        quota: Double,
        unit: String,
        factor: Double,
        indexLevelTresholds: IndexLevels.Tresholds
    ) {
        self.type = type
        self.code = code
        self.formula = formula
        self.formulaNumbersInBottomBaseline = formulaNumbersInBottomBaseline
        self.quota = quota
        self.unit = unit
        self.factor = factor
        self.indexLevelTresholds = indexLevelTresholds
    }
}
