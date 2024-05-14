//
//  SensorNetworkModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import Foundation

struct SensorNetworkModel: Decodable {
    enum CodingKeys: String, CodingKey {
        case id = "Identyfikator stanowiska"
        case paramId = "Id wskaźnika"
        case name = "Wskaźnik"
        case formula = "Wskaźnik - wzór"
        case code = "Wskaźnik - kod"
    }
    
    let id: Int
    let paramId: Int
    let name: String
    let formula: String
    let code: String
}
