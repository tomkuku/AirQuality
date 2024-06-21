//
//  AQI.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 21/06/2024.
//

import Foundation
import struct SwiftUI.Color

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

extension AQI: Comparable {
    private var priority: Int {
        switch self {
        case .undefined:                    -1
        case .good:                         1
        case .moderate:                     2
        case .unhealthyForSensitiveGroup:   3
        case .unhealthy:                    4
        case .veryUnhealthy:                5
        case .hazardus:                     6
        }
    }
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.priority < rhs.priority
    }
}
