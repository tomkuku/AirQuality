//
//  StationLocalDatabaseModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 27/05/2024.
//

import Foundation
import SwiftData

protocol LocalDatabaseModel: PersistentModel, Sendable {
    associatedtype IdentifierType: Equatable
    
    var identifier: IdentifierType { get }
    
    static func idPredicate(with id: IdentifierType) -> Predicate<Self>
}

@Model
final class StationLocalDatabaseModel: LocalDatabaseModel {
    let identifier: Int
    let latitude: Double
    let longitude: Double
    let cityName: String
    let commune: String
    let province: String
    let street: String?
    
    static func idPredicate(with id: Int) -> Predicate<StationLocalDatabaseModel> {
        #Predicate<StationLocalDatabaseModel> { model in
            model.identifier == id
        }
    }
    
    init(
        identifier: Int,
        latitude: Double,
        longitude: Double,
        cityName: String,
        commune: String,
        province: String,
        street: String?
    ) {
        self.identifier = identifier
        self.latitude = latitude
        self.longitude = longitude
        self.cityName = cityName
        self.commune = commune
        self.province = province
        self.street = street
    }
}
