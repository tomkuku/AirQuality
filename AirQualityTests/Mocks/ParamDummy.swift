//
//  ParamDummy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 16/05/2024.
//

import Foundation

@testable import AirQuality

extension Param.IndexLevels {
    static func dummy(
        good: Int = 10,
        moderate: Int = 20,
        unhealthyForSensitiveGroup: Int = 30,
        unhealthy: Int = 40,
        veryUnhealthy: Int = 50
    ) -> Self {
        Self(
            good: good,
            moderate: moderate,
            unhealthyForSensitiveGroup: unhealthyForSensitiveGroup,
            unhealthy: unhealthy,
            veryUnhealthy: veryUnhealthy
        )
    }
}

extension Param {
    static func dummy(
        type: ParamType = .c6h6,
        code: String = "c6h6",
        formula: String = "C6H6",
        quota: Double = 10,
        unit: String = "",
        indexLevels: IndexLevels = .dummy()
    ) -> Self {
        Self(
            type: .c6h6,
            code: code,
            formula: formula, 
            formulaNumbersInBottomBaseline: false,
            quota: quota,
            unit: unit,
            indexLevels: indexLevels
        )
    }
}
