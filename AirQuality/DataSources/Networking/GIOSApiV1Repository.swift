//
//  GIOSApiRepository.swift
//
//
//  Created by Tomasz Kukułka on 30/04/2024.
//

import Foundation
import Combine

protocol HasGIOSApiV1Repository {
    var giosApiV1Repository: GIOSApiV1RepositoryProtocol { get }
}

protocol GIOSApiV1RepositoryProtocol: Sendable {
    func fetch<T>(
        mapper: T,
        endpoint: any HTTPRequest,
        contentContainerName: String
    ) async throws -> T.DomainModel where T: NetworkMapperProtocol
}

actor GIOSApiV1Repository: GIOSApiV1RepositoryProtocol {
    
    // MARK: Private Properties
    
    private let jsonDecoder: JSONDecoder
    private let httpDataSource: HTTPDataSourceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Lifecycle
    
    init(
        httpDataSource: HTTPDataSourceProtocol,
        jsonDecoder: JSONDecoder = .init()
    ) {
        self.httpDataSource = httpDataSource
        self.jsonDecoder = jsonDecoder
    }
    
    // MARK: Methods
    
    func fetch<T>(
        mapper: T,
        endpoint: any HTTPRequest,
        contentContainerName: String
    ) async throws -> T.DomainModel where T: NetworkMapperProtocol {
        /// This code must be a closure because it must be called after continuation has been initialised.
        /// Otherwise, `requestData` may return data before withCheckedThrowingContinuation will be executed.
        let requestClosure: (@Sendable (isolated GIOSApiV1Repository, CheckedContinuation<T.DomainModel, Error>) -> ()) = { actorSelf, continuation in
            let cancellable = actorSelf
                .httpDataSource
                .requestData(endpoint)
                .tryCompactMap {
                    let container = try actorSelf.jsonDecoder.decode(GIOSApiV1Response.self, from: $0)
                    let networkModelObjects: T.DTOModel = try container.getValue(for: contentContainerName)
                    return try mapper.map(networkModelObjects)
                }
                .sink {
                    guard case .failure(let error) = $0 else { return }
                    
                    continuation.resume(throwing: error)
                } receiveValue: {
                    continuation.resume(returning: $0)
                }
            
            actorSelf.cancellables.insert(cancellable)
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            Task { [weak self] in
                guard let self else { return }
                
                await requestClosure(self, continuation)
            }
        }
    }
}
