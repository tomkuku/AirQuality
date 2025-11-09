//
//  StationsNetworkMapperMock.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 16/06/2024.
//

import Foundation

@testable import AirQuality

final class StationsNetworkMapperMock: StationsNetworkMapperProtocol {
    nonisolated(unsafe) var mappedStations: [Station] = []
    
    func map(_ input: [StationNetworkModel], using inputParameters: ()) throws -> [Station] {
        mappedStations
    }
}
