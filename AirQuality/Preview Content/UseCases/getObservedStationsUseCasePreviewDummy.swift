//
//  getObservedStationsUseCasePreviewDummy.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 05/07/2024.
//

import Foundation

final class GetObservedStationsUseCasePreviewDummy: GetObservedStationsUseCaseProtocol {
    nonisolated(unsafe) static var fetchedStations: Result<[Station], Error> = .success([])
    nonisolated(unsafe) static var createNewStreamStations: Result<[Station], Error> = .success([])
    
    
    func fetchedStations() async throws -> [Station] {
        try await withCheckedThrowingContinuation { continuation in
            continuation.resume(with: Self.fetchedStations)
        }
    }
    
    func createNewStream() -> AsyncThrowingStream<[Station], Error> {
        AsyncThrowingStream { continuation in
            continuation.yield(with: Self.createNewStreamStations)
        }
    }
}
