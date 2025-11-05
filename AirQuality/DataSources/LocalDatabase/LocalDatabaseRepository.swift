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
    func insert<Mapper, DomainModel>(
        mapper: Mapper,
        object: DomainModel
    ) async throws where Mapper: LocalDatabaseMapperProtocol, DomainModel == Mapper.DomainModel
    
    func delete<Mapper, DomainModel>(
        mapperType: Mapper.Type,
        object: DomainModel
    ) async throws where Mapper: LocalDatabaseMapperProtocol, DomainModel == Mapper.DomainModel
    
    func fetch<Mapper, Domain>(
        predicate: Predicate<Mapper.DTOModel>?,
        sorts: [SortDescriptor<Mapper.DTOModel>],
        mapper: Mapper,
        mapperInputParameters: Mapper.InputParameters
    ) async throws -> [Mapper.DomainModel] where Mapper: LocalDatabaseMapperProtocol, Domain == Mapper.DomainModel
}

extension LocalDatabaseRepositoryProtocol {
    func fetch<Mapper, Domain>(
        predicate: Predicate<Mapper.DTOModel>?,
        sorts: [SortDescriptor<Mapper.DTOModel>],
        mapper: Mapper
    ) async throws -> [Mapper.DomainModel]
    where
    Mapper: LocalDatabaseMapperProtocol,
    Domain == Mapper.DomainModel,
    Mapper.InputParameters == Void {
        try await fetch(predicate: predicate, sorts: sorts, mapper: mapper, mapperInputParameters: ())
    }
}

final class LocalDatabaseRepository: LocalDatabaseRepositoryProtocol, Sendable {
    
    private let localDatabaseDataSource: LocalDatabaseDataSourceProtocol
    
    init(localDatabaseDataSource: LocalDatabaseDataSourceProtocol) {
        self.localDatabaseDataSource = localDatabaseDataSource
    }
    
    func insert<Mapper, DomainModel>(
        mapper: Mapper,
        object: DomainModel
    ) async throws where Mapper: LocalDatabaseMapperProtocol, DomainModel == Mapper.DomainModel {
        let persistentModel = try mapper.map(object)
        
        await localDatabaseDataSource.insert(persistentModel)
    }
    
    func delete<Mapper, DomainModel>(
        mapperType: Mapper.Type,
        object: DomainModel
    ) async throws where Mapper: LocalDatabaseMapperProtocol, DomainModel == Mapper.DomainModel {
        let predicate = Mapper.DTOModel.idPredicate(with: object.id)
        
        guard let fetchedObject = try await localDatabaseDataSource.fetchFirst(object: Mapper.DTOModel.self, predicate: predicate) else {
            Logger.info("Object \(object) not found. Deletion is not possible!")
            return
        }
        
        await localDatabaseDataSource.delete(fetchedObject)
    }
    
    func fetch<Mapper, Domain>(
        predicate: Predicate<Mapper.DTOModel>?,
        sorts: [SortDescriptor<Mapper.DTOModel>],
        mapper: Mapper,
        mapperInputParameters: Mapper.InputParameters
    ) async throws -> [Mapper.DomainModel] where Mapper: LocalDatabaseMapperProtocol, Domain == Mapper.DomainModel {
        try await localDatabaseDataSource.fetch(
            object: Mapper.DTOModel.self,
            predicate: predicate,
            sorts: sorts
        )
        .map {
            try mapper.map($0, using: mapperInputParameters)
        }
    }
}
