//
//  SensorPreviewDummy.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 12/05/2024.
//

import Foundation

extension Sensor {
    static func previewDummy(
        id: Int = 12,
        name: String = "Benzene",
        formula: String = "C6H6",
        code: String = "C6H6"
    ) -> Self {
        let paramIndexLevels = Param.IndexLevels(
            veryGood: 10,
            good: 20,
            moderate: 30,
            sufficient: 40,
            bad: 50
        )
        
        let param = Param(
            type: .c6h6,
            code: "C6H6",
            quota: 25,
            indexLevels: paramIndexLevels
        )
        
        let measurements: [Measurement] = [
            Measurement(date: Date(), value: 12),
            Measurement(date: Date(), value: 24),
            Measurement(date: Date(), value: nil)
        ]
        
        return Self(
            id: 11,
            param: param,
            measurements: measurements
        )
    }
}
