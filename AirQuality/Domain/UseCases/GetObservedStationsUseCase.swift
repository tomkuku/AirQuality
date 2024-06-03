//
//  GetObservedStationsUseCase.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 30/05/2024.
//

import Foundation
import struct SwiftData.FetchDescriptor

protocol GetObservedStationsUseCaseProtocol: Sendable {
    func fetchedStations() async throws -> [Station]
    
    func observe() -> AsyncThrowingStream<[Station], Error>
}

final class GetObservedStationsUseCase: GetObservedStationsUseCaseProtocol, Sendable {
    @Injected(\.localDatabaseRepository) private var localDatabaseRepository
    
    private var stationsLocalDatabaseMapper: any StationsLocalDatabaseMapperProtocol
    
    init(stationsLocalDatabaseMapper: any StationsLocalDatabaseMapperProtocol = StationsLocalDatabaseMapper()) {
        self.stationsLocalDatabaseMapper = stationsLocalDatabaseMapper
    }
    
    func fetchedStations() async throws -> [Station] {
        try await localDatabaseRepository.getFetchedStations()
    }
    
    func observe() -> AsyncThrowingStream<[Station], Error> {
        localDatabaseRepository.ceateObservedStationsStrem(mapper: stationsLocalDatabaseMapper)
    }
}