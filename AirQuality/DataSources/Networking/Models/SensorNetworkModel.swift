//
//  SensorNetworkModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import Foundation

struct SensorNetworkModel: Decodable {
    struct Param: Decodable {
        let idParam: Int
    }
    
    let id: Int
    let param: Param
}
