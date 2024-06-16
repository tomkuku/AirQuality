//
//  FindTheNearestStationUseCasePreviewDummy.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 13/06/2024.
//

import Foundation

final class FindTheNearestStationUseCasePreviewDummy: FindTheNearestStationUseCaseProtocol {
    nonisolated(unsafe) static var theNearestStation: (station: Station, distance: Double)?
    
    func find() async throws -> (station: Station, distance: Double)? {
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        
        return Self.theNearestStation
    }
}
