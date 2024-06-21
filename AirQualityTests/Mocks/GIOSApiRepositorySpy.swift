//
//  GIOSApiRepositorySpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 12/05/2024.
//

import XCTest

@testable import AirQuality

final class GIOSApiRepositorySpy: GIOSApiRepositoryProtocol, @unchecked Sendable {
    enum Event: Equatable {
        case fetch(String, URLRequest, SourceType)
        case fetchSensors(Int)
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case let (.fetch(method1, request1, source1), .fetch(method2, request2, source2)):
                method1 == method2 && request1 == request2 && source1 == source2
            case let (.fetchSensors(lhsSensorId), .fetchSensors(rhsSensorId)):
                lhsSensorId == rhsSensorId
            default:
                false
            }
        }
    }
    
    private(set) var events: [Event] = []
    
    var fetchResult: Result<Any, Error>?
    var fetchSensorsResult: Result<[Sensor], Error>?
    
    func fetch<T>(
        mapper: T,
        endpoint: any HTTPRequest,
        source: SourceType
    ) async throws -> T.DomainModel where T: NetworkMapperProtocol {
        events.append(.fetch(String(describing: T.DomainModel.self), try! endpoint.asURLRequest(), source))
        
        return try await withCheckedThrowingContinuation { continuation in
            switch fetchResult {
            case .success(let domainModel):
                continuation.resume(returning: domainModel as! T.DomainModel)
            case .failure(let error):
                continuation.resume(throwing: error)
            case .none:
                XCTFail("Result should have been set!")
            }
        }
    }
    
    func fetchSensors(for stationId: Int) async throws -> [Sensor] {
        events.append(.fetchSensors(stationId))
        
        return try await withCheckedThrowingContinuation { continuation in
            switch fetchSensorsResult {
            case .success(let sensors):
                continuation.resume(returning: sensors)
            case .failure(let error):
                continuation.resume(throwing: error)
            case .none:
                fatalError("Result should have been set!")
            }
        }
    }
}
