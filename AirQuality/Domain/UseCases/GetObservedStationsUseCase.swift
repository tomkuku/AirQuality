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
    
    func createNewStream() -> AsyncThrowingStream<[Station], Error>
}

final class GetObservedStationsUseCase: GetObservedStationsUseCaseProtocol, @unchecked Sendable {
    @Injected(\.observedStationsFetchResultsRepository) private var observedStationsFetchResultsRepository
    
    private var stationsLocalDatabaseMapper: any StationsLocalDatabaseMapperProtocol
    
    init(stationsLocalDatabaseMapper: any StationsLocalDatabaseMapperProtocol = StationsLocalDatabaseMapper()) {
        self.stationsLocalDatabaseMapper = stationsLocalDatabaseMapper
    }
    
    func fetchedStations() async throws -> [Station] {
        try await observedStationsFetchResultsRepository.getFetchedObjects()
    }
    
    func createNewStream() -> AsyncThrowingStream<[Station], Error> {
        observedStationsFetchResultsRepository.ceateNewStrem()
    }
}
