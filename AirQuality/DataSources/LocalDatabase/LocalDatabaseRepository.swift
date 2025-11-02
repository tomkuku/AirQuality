//
//  LocalDatabaseRepository.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 27/05/2024.
//

import Foundation
import SwiftData

protocol HasLocalDatabaseRepository {
    var localDatabaseRepository: LocalDatabaseRepositoryProtocol { get }
}

protocol LocalDatabaseRepositoryProtocol: Sendable {
    func insert<T, L>(mapper: T, object: L) async throws where T: LocalDatabaseMapperProtocol, L == T.DomainModel
    
    func delete<T, D>(
        mapperType: T.Type,
        object: D
    ) async throws where T: LocalDatabaseMapperProtocol, D == T.DomainModel
    
    func fetch<Mapper, Domain>(
        predicate: Predicate<Mapper.DTOModel>?,
        sorts: [SortDescriptor<Mapper.DTOModel>],
        mapper: Mapper
    ) async throws -> [Mapper.DomainModel] where Mapper: LocalDatabaseMapperProtocol, Domain == Mapper.DomainModel
}

final class LocalDatabaseRepository: LocalDatabaseRepositoryProtocol, Sendable {
    
    private let localDatabaseDataSource: LocalDatabaseDataSourceProtocol
    
    init(localDatabaseDataSource: LocalDatabaseDataSourceProtocol) {
        self.localDatabaseDataSource = localDatabaseDataSource
    }
    
    func insert<T, L>(
        mapper: T,
        object: L
    ) async throws where T: LocalDatabaseMapperProtocol, L == T.DomainModel {
        let persistentModel = try mapper.map(object)
        
        await localDatabaseDataSource.insert(persistentModel)
    }
    
    func delete<T, D>(
        mapperType: T.Type,
        object: D
    ) async throws where T: LocalDatabaseMapperProtocol, D == T.DomainModel {
        let predicate = T.DTOModel.idPredicate(with: object.id)
        
        guard let fetchedObject = try await localDatabaseDataSource.fetchFirst(object: T.DTOModel.self, predicate: predicate) else {
            Logger.info("Object \(object) not found. Deletion is not possible!")
            return
        }
        
        await localDatabaseDataSource.delete(fetchedObject)
    }
    
    func fetch<Mapper, Domain>(
        predicate: Predicate<Mapper.DTOModel>?,
        sorts: [SortDescriptor<Mapper.DTOModel>],
        mapper: Mapper
    ) async throws -> [Mapper.DomainModel] where Mapper: LocalDatabaseMapperProtocol, Domain == Mapper.DomainModel {
        try await localDatabaseDataSource.fetch(
            object: Mapper.DTOModel.self,
            predicate: predicate,
            sorts: sorts
        )
        .map {
            try mapper.map($0)
        }
    }
}
