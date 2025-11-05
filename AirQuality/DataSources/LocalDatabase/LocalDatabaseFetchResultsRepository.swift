//
//  LocalDatabaseFetchResultsRepository.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 05/06/2024.
//

import Foundation

protocol LocalDatabaseFetchResultsRepositoryProtocol<Mapper>: Sendable {
    associatedtype Mapper: LocalDatabaseMapperProtocol
    
    func getFetchedObjects(mapperInputParameters: Mapper.InputParameters) async throws -> [Mapper.DomainModel]
    func createNewStream(with mapperInputParameters: Mapper.InputParameters) -> AsyncThrowingStream<[Mapper.DomainModel], Error>
}

extension LocalDatabaseFetchResultsRepositoryProtocol {
    func getFetchedObjects() async throws -> [Mapper.DomainModel] where Mapper.InputParameters == Void {
        try await getFetchedObjects(mapperInputParameters: ())
    }
    
    func createNewStream() -> AsyncThrowingStream<[Mapper.DomainModel], Error> where Mapper.InputParameters == Void {
        createNewStream(with: ())
    }
}

final class LocalDatabaseFetchResultsRepository<Mapper>: LocalDatabaseFetchResultsRepositoryProtocol where Mapper: LocalDatabaseMapperProtocol {
    typealias Mapper = Mapper
    
    // MARK: Private properties
    
    private let localDatabaseFetchResultsDataSource: any LocalDatabaseFetchResultsDataSourceProtocol<Mapper.DTOModel>
    private let mapper: Mapper
    
    // MARK: Lifecycle
    
    init(
        localDatabaseFetchResultsDataSource: any LocalDatabaseFetchResultsDataSourceProtocol<Mapper.DTOModel>,
        mapper: Mapper
    ) {
        self.localDatabaseFetchResultsDataSource = localDatabaseFetchResultsDataSource
        self.mapper = mapper
    }
    
    // MARK: Methods
    
    func getFetchedObjects(mapperInputParameters: Mapper.InputParameters) async throws -> [Mapper.DomainModel] {
        try await localDatabaseFetchResultsDataSource
            .fetchedModels
            .map {
                try mapper.map($0, using: mapperInputParameters)
            }
    }
    
    func createNewStream(with mapperInputParameters: Mapper.InputParameters) -> AsyncThrowingStream<[Mapper.DomainModel], Error> {
        AsyncThrowingStream { continuation in
            Task { [weak self] in
                guard let self else { return }
                
                do {
                    for try await models in try await localDatabaseFetchResultsDataSource.createNewStrem() {
                        let mappedModels = try models.map {
                            try self.mapper.map($0, using: mapperInputParameters)
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
