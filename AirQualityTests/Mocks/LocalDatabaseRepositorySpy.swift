//
//  LocalDatabaseRepositorySpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 16/06/2024.
//

import Foundation

@testable import AirQuality

final class LocalDatabaseRepositorySpy: LocalDatabaseRepositoryProtocol, @unchecked Sendable {
    enum Event {
        case insert
        case delete
    }
    
    var events: [Event] = []
    
    var insertThrowError: Error?
    var deleteThrowError: Error?
    
    func insert<T, L>(
        mapper: T,
        object: L
    ) async throws where T: LocalDatabaseMapperProtocol, L == T.DomainModel {
        events.append(.insert)
        
        if let insertThrowError {
            throw insertThrowError
        }
    }
    
    func delete<T, D>(
        mapperType: T.Type,
        object: D
    ) async throws where T: LocalDatabaseMapperProtocol, D == T.DomainModel {
        events.append(.delete)
        
        if let deleteThrowError {
            throw deleteThrowError
        }
    }
    
    func fetch<Mapper, Domain>(
        predicate: Predicate<Mapper.DTOModel>?,
        sorts: [SortDescriptor<Mapper.DTOModel>],
        mapper: Mapper,
        mapperInputParameters: Mapper.InputParameters
    ) async throws -> [Mapper.DomainModel] where Mapper: LocalDatabaseMapperProtocol, Domain == Mapper.DomainModel {
        []
    }
}
