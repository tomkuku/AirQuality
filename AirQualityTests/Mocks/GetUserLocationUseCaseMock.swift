//
//  GetUserLocationUseCaseMock.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 06/11/2025.
//

import Foundation
import Combine
import XCTest

@testable import AirQuality

final class GetUserLocationUseCaseMock: GetUserLocationUseCaseProtocol, @unchecked Sendable {
    enum Event {
        case checkLocationServicesAvailability
        case streamLocation
        case streamLocationFinish
    }
    
    var events: [Event] = []
    
    let locationStremSubject = PassthroughSubject<Location, Error>()
    
    private var cancellables = Set<AnyCancellable>()
    
    var expectation: XCTestExpectation?
    var checkLocationServicesAvailabilityThrowError: UserLocationServicesError?
    
    func checkLocationServicesAvailability() async throws {
        events.append(.checkLocationServicesAvailability)
        
        if let checkLocationServicesAvailabilityThrowError {
            throw checkLocationServicesAvailabilityThrowError
        }
    }
    
    var streamLocationHandler: (() -> ())?
    
    func streamLocation(
        finishClosure: inout (@Sendable () -> ())?
    ) async -> AsyncThrowingStream<Location, Error> {
        defer {
            streamLocationHandler?()
        }
        
        events.append(.streamLocation)
        
        finishClosure = {
            self.events.append(.streamLocationFinish)
            self.expectation?.fulfill()
        }
        
        return AsyncThrowingStream { continuation in
            locationStremSubject
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
