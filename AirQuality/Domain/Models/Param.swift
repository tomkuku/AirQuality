//
//  Param.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 14/05/2024.
//

import Foundation
import struct SwiftUI.Color

enum ParamType: Int, Equatable {
    case c6h6 = 10
    case pm10 = 3
    case pm25 = 69
    case o3 = 5
    case no2 = 6
    case so2 = 1
    case co = 8
}

enum AQI {
    case good
    case moderate
    case unhealthyForSensitiveGroup
    case unhealthy
    case veryUnhealthy
    case hazardus
    case undefined
    
    var color: Color {
        switch self {
        case .good:
            Color("good")
        case .moderate:
            Color("moderate")
        case .unhealthyForSensitiveGroup:
            Color("unhealthyForSensitiveGroup")
        case .unhealthy:
            Color("unhealthy")
        case .veryUnhealthy:
            Color("veryUnhealthy")
        case .hazardus:
            Color("hazardus")
        case .undefined:
            Color("undefined")
        }
    }
}

struct Param: Sendable, Equatable {
    let type: ParamType
    let code: String
    let quota: Double
    let indexLevels: IndexLevels
    
    func getAqi(for value: Double) -> AQI {
        switch Int(value) {
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
            fatalError()
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
