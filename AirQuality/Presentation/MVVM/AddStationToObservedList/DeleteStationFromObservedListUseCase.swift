//
//  DeleteStationFromObservedListUseCase.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 31/05/2024.
//

import Foundation

protocol DeleteStationFromObservedListUseCaseProtocol: Sendable {
    func delete(station: Station) async throws
}

final class DeleteStationFromObservedListUseCase: DeleteStationFromObservedListUseCaseProtocol, @unchecked Sendable {
    @Injected(\.localDatabaseRepository) private var localDatabaseRepository
    
    private let stationsLocalDatabaseMapper: any StationsLocalDatabaseMapperProtocol
    
    init(stationsLocalDatabaseMapper: any StationsLocalDatabaseMapperProtocol = StationsLocalDatabaseMapper()) {
        self.stationsLocalDatabaseMapper = stationsLocalDatabaseMapper
    }
    
    func delete(station: Station) async throws {
        try await localDatabaseRepository.delete(
            mapper: stationsLocalDatabaseMapper,
            object: station
        )
    }
}
