//
//  GetObservedStationsUseCase.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 30/05/2024.
//

import Foundation
import struct SwiftData.FetchDescriptor

protocol HasGetObservedStationsUseCase {
    var getObservedStationsUseCase: GetObservedStationsUseCaseProtocol { get }
}

protocol GetObservedStationsUseCaseProtocol: Sendable {
    func fetchedStations() async throws -> [Station]
    func createNewStream() -> AsyncThrowingStream<[Station], Error>
}

final class GetObservedStationsUseCase: GetObservedStationsUseCaseProtocol {
    @Injected(\.observedStationsFetchResultsRepository) private var observedStationsFetchResultsRepository
    @Injected(\.stationsLocalDatabaseMapper) private var stationsLocalDatabaseMapper
    
    init() { }
    
    func fetchedStations() async throws -> [Station] {
        try await observedStationsFetchResultsRepository.getFetchedObjects()
    }
    
    func createNewStream() -> AsyncThrowingStream<[Station], Error> {
        observedStationsFetchResultsRepository.ceateNewStrem()
    }
}
