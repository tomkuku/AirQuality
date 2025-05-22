//
//  StationLocalDatabaseModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 27/05/2024.
//

import Foundation
import SwiftData

protocol LocalDatabaseModel: PersistentModel, Sendable {
    associatedtype IdentifierType: Equatable, Sendable
    
    var identifier: IdentifierType { get }
    
    static func idPredicate(with id: IdentifierType) -> Predicate<Self>
}

@Model
final class StationLocalDatabaseModel: LocalDatabaseModel, @unchecked Sendable {
    var latitude: Double
    var identifier: Int
    var longitude: Double
    var cityName: String
    var province: String
    var street: String?
    
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
        province: String,
        street: String?
    ) {
        self.identifier = identifier
        self.latitude = latitude
        self.longitude = longitude
        self.cityName = cityName
        self.province = province
        self.street = street
    }
}
