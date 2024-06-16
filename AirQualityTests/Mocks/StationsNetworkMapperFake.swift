//
//  StationsNetworkMapperFake.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 16/06/2024.
//

import Foundation

@testable import AirQuality

final class StationsNetworkMapperFake: StationsNetworkMapperProtocol {
    func map(_ input: [StationNetworkModel]) throws -> [Station] {
        []
    }
}
