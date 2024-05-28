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
    func insert<T: LocalDatabaseMapperProtocol>(mapper: T.Type, object: T.DomainModel) async throws
    
//    func fetch<T>(
//        _ fetchDescription: FetchDescriptor<T>
//    ) async throws -> [T] where T: PersistentModel & Sendable
}

final class LocalDatabaseRepository: LocalDatabaseRepositoryProtocol {
    private let localDatabaseDataStore: LocalDatabaseDataStoreProtocol
    
    init(localDatabaseDataStore: LocalDatabaseDataStoreProtocol) {
        self.localDatabaseDataStore = localDatabaseDataStore
    }
    
    func insert<T: LocalDatabaseMapperProtocol>(mapper: T.Type, object: T.DomainModel) async throws {
        let mapper = T()
        let databaseObject = try mapper.mapDomainModel(object)
        
        await localDatabaseDataStore.insert(databaseObject)
    }
    
//    func fetch<T>(
//        _ fetchDescription: FetchDescriptor<T>
//    ) async throws -> [T] where T: PersistentModel & Sendable {
//        try await localDatabaseDataStore.fetch(fetchDescription)
//    }
}
