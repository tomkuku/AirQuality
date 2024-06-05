//
//  File.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 05/06/2024.
//

import Foundation
@testable import AirQuality

struct DomainModelDummy: Sendable, Identifiable, Equatable {
    let id: Int
    
    init(id: Int = 1) {
        self.id = id
    }
}
