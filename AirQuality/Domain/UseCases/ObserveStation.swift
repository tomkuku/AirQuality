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
    
    private let stationsLocalDatabaseMapper: any StationsLocalDatabaseMapperProtocol
    
    init(stationsLocalDatabaseMapper: any StationsLocalDatabaseMapperProtocol = StationsLocalDatabaseMapper()) {
        self.stationsLocalDatabaseMapper = stationsLocalDatabaseMapper
    }
    
    @HandlerActor
    func observe(station: Station) async throws {
        try await localDatabaseRepository.insert(
            mapper: stationsLocalDatabaseMapper,
            object: station
        )
    }
}
