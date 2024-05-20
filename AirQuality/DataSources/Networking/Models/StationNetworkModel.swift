//
//  StationNetworkModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 01/05/2024.
//

import Foundation

struct StationNetworkModel: Decodable {
    enum CodingKeys: String, CodingKey {
        case id = "Identyfikator stacji"
        case name = "Nazwa stacji"
        case latitude = "WGS84 φ N"
        case longitude = "WGS84 λ E"
        case cityName = "Nazwa miasta"
        case commune = "Gmina"
        case province = "Województwo"
        case street = "Ulica"
    }
    
    let id: Int
    let name: String
    let latitude: String
    let longitude: String
    let cityName: String
    let commune: String
    let province: String
    let street: String
}
