//
//  LocalDatabaseModelDummy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 05/06/2024.
//

import Foundation
import SwiftData

@testable import AirQuality

@Model
final class LocalDatabaseModelDummy: LocalDatabaseModel, @unchecked Sendable {
    static func idPredicate(with id: Int) -> Predicate<LocalDatabaseModelDummy> {
        #Predicate<LocalDatabaseModelDummy> { model in
            model.identifier == id
        }
    }
    
    init(identifier: Int = 1) {
        self.identifier = identifier
    }
    
    let identifier: Int
}
