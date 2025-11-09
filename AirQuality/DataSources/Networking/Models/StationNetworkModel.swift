//
//  StationNetworkModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 01/05/2024.
//

import Foundation

/*
 {
    "Identyfikator stacji": 71,
    "Kod stacji": "DsOlesBrzozo",
    "Nazwa stacji": "Oleśnica, ul. Brzozowa",
    "WGS84 φ N": "51.217483",
    "WGS84 λ E": "17.389997",
    "Identyfikator miasta": 637,
    "Nazwa miasta": "Oleśnica",
    "Gmina": "Oleśnica",
    "Powiat": "oleśnicki",
    "Województwo": "DOLNOŚLĄSKIE",
    "Ulica": "ul. Brzozowa 7"
 }
 */

struct StationNetworkModel: Decodable {
    enum CodingKeys: String, CodingKey {
        case id = "Identyfikator stacji"
        case latitude = "WGS84 φ N"
        case longitude = "WGS84 λ E"
        case cityName = "Nazwa miasta"
        case province = "Województwo"
        case street = "Ulica"
    }
    
    let id: Int
    let latitude: String
    let longitude: String
    let cityName: String
    let province: String
    let street: String?
}
