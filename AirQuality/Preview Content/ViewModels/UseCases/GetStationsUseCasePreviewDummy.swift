//
//  GetStationsUseCasePreviewDummy.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 07/06/2024.
//

import Foundation

final class GetStationsUseCasePreviewDummy: GetStationsUseCaseProtocol, @unchecked Sendable {
    
    func getStations() async throws -> [Station] {
        Self.getStationsReturnValue
    }
}
