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
        veryGood: Int = 10,
        good: Int = 20,
        moderate: Int = 30,
        sufficient: Int = 40,
        bad: Int = 50
    ) -> Self {
        Self(
            veryGood: veryGood,
            good: good,
            moderate: moderate,
            sufficient: sufficient,
            bad: bad
        )
    }
}

extension Param {
    static func dummy(
        type: ParamType = .c6h6,
        code: String = "c6h6",
        formula: String = "C6H6",
        quota: Double = 10,
        indexLevels: IndexLevels = .dummy()
    ) -> Self {
        Self(
            type: .c6h6,
            code: code,
            formula: formula,
            quota: quota,
            indexLevels: indexLevels
        )
    }
}
