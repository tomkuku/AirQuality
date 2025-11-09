//
//  ParamDescription.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 27/08/2025.
//

import Foundation

extension Param {
    struct Description: Equatable {
        let general: String
        let environmentalImpact: String
        let humanHealthImpact: String
    }
}
