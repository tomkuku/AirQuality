//
//  GetStationsUseCasePreviewDummy.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 07/06/2024.
//

import Foundation

final class FetchAllStationsUseCasePreviewDummy: FetchAllStationsUseCaseProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var fetchReturnValue: [Station] = []
    
    func fetch() async throws -> [Station] {
        Self.fetchReturnValue
    }
}
