//
//  ObserveStation.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 28/05/2024.
//

import Foundation

protocol ObserveStationUseCaseProtocol: Sendable {
    @HandlerActor
    func observe(station: Station) async throws
}

final class ObserveStationUseCase: ObserveStationUseCaseProtocol, @unchecked Sendable {
    @Injected(\.localDatabaseRepository) private var localDatabaseRepository
    
    @HandlerActor
    func observe(station: Station) async throws {
        try await localDatabaseRepository.insert(
            mapper: StationsLocalDatabaseMapper.self,
            object: station
        )
    }
}
