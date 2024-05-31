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
    
    func delete<T, L>(mapper: T, object: L) async throws where T: LocalDatabaseMapperProtocol, L == T.DomainModel
    
    func observe<T, L, R>(
        mapper: T,
        fetchDescriptor: FetchDescriptor<L>
    ) -> AsyncThrowingStream<[R], Error> where T: LocalDatabaseMapperProtocol, L == T.DTOModel, R == T.DomainModel
}

final class LocalDatabaseRepository: LocalDatabaseRepositoryProtocol {
    private let localDatabaseDataStore: LocalDatabaseDataStoreProtocol
    
    init(localDatabaseDataStore: LocalDatabaseDataStoreProtocol) {
        self.localDatabaseDataStore = localDatabaseDataStore
    }
    
    func insert<T, L>(
        mapper: T,
        object: L
    ) async throws where T: LocalDatabaseMapperProtocol, L == T.DomainModel {
        let persistentModel = try mapper.mapDomainModel(object)
        
        await localDatabaseDataStore.insert(persistentModel)
    }
    
    func delete<T, L>(
        mapper: T,
        object: L
    ) async throws where T: LocalDatabaseMapperProtocol, L == T.DomainModel {
        let persistentModel = try mapper.mapDomainModel(object)
        
        await localDatabaseDataStore.delete(persistentModel)
    }
    
    func observe<T, L, R>(
        mapper: T,
        fetchDescriptor: FetchDescriptor<L>
    ) -> AsyncThrowingStream<[R], Error> where T: LocalDatabaseMapperProtocol, L == T.DTOModel, R == T.DomainModel {
        AsyncThrowingStream { continuation in
            Task { [weak localDatabaseDataStore] in
                guard let localDatabaseDataStore else { return }
                
                for try await models in await localDatabaseDataStore.fetchStream(fetchDescriptor: fetchDescriptor) {
                    do {
                        let mappedModels = try models.map {
                            try mapper.map($0)
                        }
                        
                        continuation.yield(mappedModels)
                    } catch {
                        continuation.yield(with: .failure(error))
                    }
                }
            }
        }
    }
}
