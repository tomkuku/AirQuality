//
//  Params.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 21/06/2024.
//

import Foundation

extension Param {
    static let pm10 = Param(
        type: .pm10,
        code: "pm10",
        formula: "PM10",
        quota: 50,
        indexLevels: Param.IndexLevels(
            veryGood: 20,
            good: 60,
            moderate: 100,
            sufficient: 140,
            bad: 200
        )
    )
    
    static let pm25 = Param(
        type: .pm25,
        code: "pm2.5",
        formula: "PM2.5",
        quota: 25,
        indexLevels: Param.IndexLevels(
            veryGood: 12,
            good: 36,
            moderate: 60,
            sufficient: 84,
            bad: 120
        )
    )
    
    static let no2 = Param(
        type: .no2,
        code: "no2",
        formula: "NO2",
        quota: 200,
        indexLevels: Param.IndexLevels(
            veryGood: 40,
            good: 100,
            moderate: 150,
            sufficient: 200,
            bad: 400
        )
    )
    
    static let co = Param(
        type: .co,
        code: "co",
        formula: "CO",
        quota: 10000,
        indexLevels: Param.IndexLevels(
            veryGood: 2000,
            good: 6000,
            moderate: 10000,
            sufficient: 14000,
            bad: 20000
        )
    )
    
    static let c6h6 = Param(
        type: .c6h6,
        code: "c6h6",
        formula: "C6H6",
        quota: 5,
        indexLevels: Param.IndexLevels(
            veryGood: 5,
            good: 10,
            moderate: 15,
            sufficient: 20,
            bad: 50
        )
    )
    
    static let o3 = Param(
        type: .o3,
        code: "o3",
        formula: "O3",
        quota: 120,
        indexLevels: Param.IndexLevels(
            veryGood: 70,
            good: 120,
            moderate: 150,
            sufficient: 180,
            bad: 240
        )
    )
    
    static let so2 = Param(
        type: .so2,
        code: "so2",
        formula: "SO2",
        quota: 125,
        indexLevels: Param.IndexLevels(
            veryGood: 50,
            good: 100,
            moderate: 200,
            sufficient: 350,
            bad: 500
        )
    )
}
