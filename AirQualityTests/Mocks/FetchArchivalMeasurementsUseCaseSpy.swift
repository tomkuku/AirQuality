//
//  FetchArchivalMeasurementsUseCaseSpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 19/06/2024.
//

import Foundation
import XCTest

@testable import AirQuality

final class FetchArchivalMeasurementsUseCaseSpy: FetchArchivalMeasurementsUseCaseProtocol, @unchecked Sendable {
    enum Event: Equatable {
        case fetchNextPage
        case refresh
        case getStream
        case setParameters
        case getParameters
    }
    
    var events: [Event] = []
    var expectation: XCTestExpectation?
    
    private var capturedParameters: SensorArchivalMeasurementsListOptions?
    
    var fetchNextPageResult: Result<Void, Error>?
    var refreshResult: Result<Void, Error>?
    var getParametersResult: SensorArchivalMeasurementsListOptions?
    var streamValues: [(pageContent: [SensorMeasurement], areMorePages: Bool)] = []
    var streamContinuation: AsyncStream<(pageContent: [SensorMeasurement], areMorePages: Bool)>.Continuation?
    
    // MARK: Protocol requirements
    
    func fetchNextPage() async throws {
        events.append(.fetchNextPage)
        
        if let result = fetchNextPageResult {
            switch result {
            case .success:
                break
            case .failure(let error):
                throw error
            }
        }
        
        expectation?.fulfill()
    }
    
    func refresh() async throws {
        events.append(.refresh)
        
        if let result = refreshResult {
            switch result {
            case .success:
                break
            case .failure(let error):
                throw error
            }
        }
        
        expectation?.fulfill()
    }
    
    func getStream() async -> AsyncStream<(pageContent: [SensorMeasurement], areMorePages: Bool)> {
        defer {
            expectation?.fulfill()
        }
        
        events.append(.getStream)
        
        return AsyncStream { continuation in
            Task {
                await self.setStreamContinuation(continuation)
                
                let values = self.streamValues
                for value in values {
                    continuation.yield(value)
                }
            }
        }
    }
    
    func setParameters(_ parameters: SensorArchivalMeasurementsListOptions) async {
        expectation?.fulfill()
        
        events.append(.setParameters)
        capturedParameters = parameters
    }
    
    func getParameters() async -> SensorArchivalMeasurementsListOptions {
        defer {
            expectation?.fulfill()
        }
        
        events.append(.getParameters)
        
        return getParametersResult ?? SensorArchivalMeasurementsListOptions(
            filters: .init(dateFrom: Date(), dateTo: Date()),
            sorting: .init(date: .descending)
        )
    }
    
    func yieldStreamValue(_ value: (pageContent: [SensorMeasurement], areMorePages: Bool)) async {
        streamContinuation?.yield(value)
    }
    
    private func setStreamContinuation(_ continuation: AsyncStream<(pageContent: [SensorMeasurement], areMorePages: Bool)>.Continuation) async {
        streamContinuation = continuation
    }
}
