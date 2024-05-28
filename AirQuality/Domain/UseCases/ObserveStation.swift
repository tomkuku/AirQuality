//
//  ObserveStation.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 28/05/2024.
//

import Foundation

@HandlerActor
protocol ObserveStationUseCaseProtocol: Sendable {
    func observe(station: Station) async throws
}

@HandlerActor
final class ObserveStationUseCase: ObserveStationUseCaseProtocol, @unchecked Sendable {
    @Injected(\.localDatabaseRepository) private var localDatabaseRepository
    
    func observe(station: Station) async throws {
        try await localDatabaseRepository.insert(
            mapper: StationsLocalDatabaseMapper.self,
            object: station
        )
    }
}
