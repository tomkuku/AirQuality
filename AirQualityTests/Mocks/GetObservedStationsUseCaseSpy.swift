//
//  GetObservedStationsUseCaseSpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 18/06/2024.
//

import XCTest
import Combine

@testable import AirQuality

final class GetObservedStationsUseCaseSpy: GetObservedStationsUseCaseProtocol, @unchecked Sendable {
    enum Event: Equatable {
        case fetchedStations
        case createNewStream
    }
    
    var events: [Event] = []
    
    var fetchStationsResult: Result<[Station], Error>?
    
    /// Simulates behavior in which a stream emits values as soon as it is created.
    var createNewStreamInitialValue: [Station]?
    
    let stationsStremSubject = PassthroughSubject<[Station], Error>()
    var expectation: XCTestExpectation?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchedStations() async throws -> [Station] {
        events.append(.fetchedStations)
        
        return try await withCheckedThrowingContinuation { continuation in
            guard let fetchStationsResult else {
                XCTFail("Unhandled fetchStationsResult")
                return
            }
            
            continuation.resume(with: fetchStationsResult)
        }
    }
    
    func createNewStream() -> AsyncThrowingStream<[Station], Error> {
        defer {
            expectation?.fulfill()
        }
        
        events.append(.createNewStream)
        
        return AsyncThrowingStream { continuation in
            if let stations = self.createNewStreamInitialValue {
                continuation.yield(stations)
            }
            
            self.stationsStremSubject
                .sink {
                    switch $0 {
                    case .finished:
                        continuation.finish()
                    case .failure(let error):
                        continuation.finish(throwing: error)
                    }
                } receiveValue: {
                    continuation.yield($0)
                }
                .store(in: &self.cancellables)
        }
    }
}
