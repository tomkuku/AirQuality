//
//  ParamBundleModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 14/05/2024.
//

import Foundation

struct ParamBundleModel: Decodable {
    struct IndexLevels: Decodable {
        let veryGood: Int
        let good: Int
        let moderate: Int
        let sufficient: Int
        let bad: Int
    }
    
    let id: Int
    let code: String
    let quota: Double
    let indexLevels: IndexLevels
}
