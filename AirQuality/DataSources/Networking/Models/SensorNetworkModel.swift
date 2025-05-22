//
//  SensorNetworkModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import Foundation

/*
{
  "Wskaźnik - kod" : "PM10",
  "Identyfikator stacji" : 398,
  "Wskaźnik - wzór" : "PM10",
  "Id wskaźnika" : 3,
  "Identyfikator stanowiska" : 2734,
  "Wskaźnik" : "pył zawieszony PM10"
}
*/


struct SensorNetworkModel: Decodable {
    enum CodingKeys: String, CodingKey{
        case idParam = "Id wskaźnika"
        case id = "Identyfikator stanowiska"
    }
    
    let id: Int
    let idParam: Int
}
