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
        Self(
            id: id,
            name: name,
            formula: formula,
            code: code
        )
    }
}
