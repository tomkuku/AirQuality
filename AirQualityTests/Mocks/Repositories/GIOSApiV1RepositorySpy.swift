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
    struct Event: Equatable {
        let mapperTypeName: String
        let request: URLRequest
        let parametersTypeName: String
        
        init<Mapper>(
            mapperType: Mapper.Type,
            request: URLRequest,
        ) where Mapper: NetworkMapperProtocol {
            self.request = request
            self.mapperTypeName = String(describing: Mapper.Type.self)
            self.parametersTypeName = String(describing: Mapper.InputParameters.Type.self)
        }
        
        static func fetch<Mapper>(
            mapperType: Mapper.Type,
            request: URLRequest,
        ) -> Self where Mapper: NetworkMapperProtocol {
            Self(mapperType: mapperType, request: request)
        }
        
        static func fetchAllStations() -> Self {
            let request = Endpoint.Stations.get(page: 0, size: 0).urlRequest!
            return Self(mapperType: StationsNetworkMapper.self, request: request)
        }
    }
    
    var events: [Event] = []
    
    var totalPages: Int = 30
    var fetchResultClosure: ((any HTTPRequest) -> (Result<Any, Error>?))?
    
    var fetchAllStationsResult: Result<[Station], Error>?
    
    // MARK: Protocol requirements
    
    func fetch<T>(
        mapper: T,
        endpoint: any HTTPRequest,
        mappingInputParameters: T.InputParameters
    ) async throws -> (output: T.DomainModel, totalPages: Int) where T: NetworkMapperProtocol {
        events.append(Event(mapperType: T.self, request: endpoint.urlRequest!))
        
        return try await withCheckedThrowingContinuation { continuation in
            switch self.fetchResultClosure?(endpoint) {
            case .success(let model):
                guard let domainModel = model as? T.DomainModel else {
                    XCTFail("Model \(String(describing: model)) can not be casted into Domain model: \(String(describing: T.DomainModel.self))")
                    continuation.resume(throwing: NSError(domain: String(describing: Self.self), code: 0))
                    return
                }
                
                continuation.resume(returning: (domainModel, totalPages))
            case .failure(let error):
                continuation.resume(throwing: error)
            case .none:
                XCTFail("Unhandled fetchResult")
                continuation.resume(throwing: NSError(domain: String(describing: Self.self), code: 0))
            }
        }
    }
    
    func fetchAllStations() async throws -> [Station] {
        events.append(.fetchAllStations())
        
        return try await withCheckedThrowingContinuation { continuation in
            switch self.fetchAllStationsResult {
            case .success(let stations):
                continuation.resume(returning: stations)
            case .failure(let error):
                continuation.resume(throwing: error)
            case .none:
                XCTFail("Unhandled fetchAllStationsResult")
                continuation.resume(throwing: NSError(domain: String(describing: Self.self), code: 0))
            }
        }
    }
}
