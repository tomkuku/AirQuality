//
//  LocalDatabaseFetchResultsRepository.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 05/06/2024.
//

import Foundation

protocol LocalDatabaseFetchResultsRepositoryProtocol<Mapper>: Sendable {
    associatedtype Mapper: LocalDatabaseMapperProtocol
    
    func getFetchedObjects() async throws -> [Mapper.DomainModel]
    func ceateNewStrem() -> AsyncThrowingStream<[Mapper.DomainModel], Error>
}

final class LocalDatabaseFetchResultsRepository<M>: LocalDatabaseFetchResultsRepositoryProtocol where M: LocalDatabaseMapperProtocol {
    typealias Mapper = M
    
    // MARK: Private properties
    
    private let localDatabaseFetchResultsDataSource: any LocalDatabaseFetchResultsDataSourceProtocol<M.DTOModel>
    private let mapper: M
    
    // MARK: Lifecycle
    
    init(
        localDatabaseFetchResultsDataSource: any LocalDatabaseFetchResultsDataSourceProtocol<M.DTOModel>,
        mapper: M
    ) {
        self.localDatabaseFetchResultsDataSource = localDatabaseFetchResultsDataSource
        self.mapper = mapper
    }
    
    // MARK: Methods
    
    func getFetchedObjects() async throws -> [M.DomainModel] {
        try await localDatabaseFetchResultsDataSource
            .fetchedModels
            .map {
                try mapper.map($0)
            }
    }
    
    func ceateNewStrem() -> AsyncThrowingStream<[M.DomainModel], Error> {
        AsyncThrowingStream { continuation in
            Task { [weak self] in
                guard let self else { return }
                
                do {
                    for try await models in try await localDatabaseFetchResultsDataSource.createNewStrem() {
                        let mappedModels = try models.map {
                            try self.mapper.map($0)
                        }
                        
                        continuation.yield(mappedModels)
                    }
                } catch {
                    continuation.yield(with: .failure(error))
                }
            }
        }
    }
}
