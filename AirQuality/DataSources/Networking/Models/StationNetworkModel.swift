//
//  StationNetworkModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 01/05/2024.
//

import Foundation

/*
{
        "id": 114,
        "stationName": "Wrocław, ul. Bartnicza",
        "gegrLat": "51.115933",
        "gegrLon": "17.141125",
        "city": {
            "id": 1064,
            "name": "Wrocław",
            "commune": {
                "communeName": "Wrocław",
                "districtName": "Wrocław",
                "provinceName": "DOLNOŚLĄSKIE"
            }
        },
        "addressStreet": "ul. Bartnicza"
    }
*/

struct StationNetworkModel: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case latitude = "gegrLat"
        case longitude = "gegrLon"
        case city
        case street = "addressStreet"
    }
    
    let id: Int
    let latitude: String
    let longitude: String
    let street: String?
    let city: City
}

extension StationNetworkModel {
    struct City: Decodable {
        let name: String
        let commune: Commune
    }
}

extension StationNetworkModel.City {
    struct Commune: Decodable {
        enum CodingKeys: String, CodingKey {
            case name = "communeName"
            case districtName
            case provinceName
        }
        
        let name: String
        let districtName: String
        let provinceName: String
    }
}
