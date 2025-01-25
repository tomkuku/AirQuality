//
//  ObserveStation.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 28/05/2024.
//

import Foundation

protocol HasAddObservedStationUseCase {
    var addObservedStationUseCase: AddObservedStationUseCaseProtocol { get }
}

protocol AddObservedStationUseCaseProtocol: Sendable {
    func add(station: Station) async throws
}

final class AddObservedStationUseCase: AddObservedStationUseCaseProtocol {
    private var stationsLocalDatabaseMapper: any StationsLocalDatabaseMapperProtocol {
        Injected[\.stationsLocalDatabaseMapper]
    }
    
    func add(station: Station) async throws {
        try await Injected[\.localDatabaseRepository].insert(
            mapper: stationsLocalDatabaseMapper,
            object: station
        )
    }
}
