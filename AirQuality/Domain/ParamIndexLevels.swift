//
//  ParamIndexLevel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 30/10/2025.
//

import Foundation

extension Param {
    enum IndexLevels: Equatable {
        case good
        case moderate
        case unhealthyForSensitiveGroup
        case unhealthy
        case veryUnhealthy
        case hazardus
        
        var description: String {
            switch self {
            case .good:
                ""
            case .moderate:
                ""
            case .unhealthyForSensitiveGroup:
                ""
            case .unhealthy:
                ""
            case .veryUnhealthy:
                ""
            case .hazardus:
                ""
            }
        }
    }
}

extension Param.IndexLevels {
    struct Tresholds: Equatable {
        let good: Int
        let moderate: Int
        let unhealthyForSensitiveGroup: Int
        let unhealthy: Int
        let veryUnhealthy: Int
    }
}
