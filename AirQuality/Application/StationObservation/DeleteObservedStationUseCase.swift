//
//  DeleteObservedStationUseCase.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 31/05/2024.
//

import Foundation

protocol HasDeleteObservedStationUseCase {
    var deleteObservedStationUseCase: DeleteObservedStationUseCaseProtocol { get }
}

protocol DeleteObservedStationUseCaseProtocol: Sendable {
    func delete(station: Station) async throws
}

final class DeleteObservedStationUseCase: DeleteObservedStationUseCaseProtocol {
    func delete(station: Station) async throws {
        try await Injected[\.localDatabaseRepository].delete(
            mapperType: StationsLocalDatabaseMapper.self,
            object: station
        )
    }
}
