//
//  GIOSApiV1RepositorySpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 18/06/2024.
//

import Foundation
import XCTest

@testable import AirQuality

final class GIOSApiV1RepositorySpy: GIOSApiV1RepositoryProtocol, @unchecked Sendable {
    enum Event: Equatable, Hashable {
        case fetch((any MapperProtocol), (any HTTPRequest)?, String)
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case let (.fetch(_, lhsRequest, lhsContainerName), .fetch(_, rhsRequest, rhsContainerName)):
                return lhsRequest?.urlRequest == rhsRequest?.urlRequest &&
                lhsContainerName == rhsContainerName
            }
        }
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .fetch(_, _, let containerName):
                hasher.combine(containerName)
            }
        }
    }
    
    var events: [Event] = []
    
    var fetchResultClosure: ((any HTTPRequest) -> (Result<Any, Error>?))?
    
    func fetch<T>(
        mapper: T,
        endpoint: any HTTPRequest,
        contentContainerName: String
    ) async throws -> T.DomainModel where T: NetworkMapperProtocol {
        events.append(.fetch(mapper, endpoint, contentContainerName))
        
        return try await withCheckedThrowingContinuation { continuation in
            switch self.fetchResultClosure?(endpoint) {
            case .success(let model):
                do {
                    guard let dtoModel = model as? T.DTOModel else {
                        XCTFail("model can not be casted into DTO model")
                        return
                    }
                    
                    let domainModel = try mapper.map(dtoModel)
                    
                    continuation.resume(returning: domainModel)
                } catch {
                    continuation.resume(throwing: error)
                }
            case .failure(let error):
                continuation.resume(throwing: error)
            case .none:
                XCTFail("Unhandled fetchResult")
            }
        }
    }
}
