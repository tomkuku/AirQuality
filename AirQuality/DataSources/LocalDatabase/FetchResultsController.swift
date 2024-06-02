//
//  FetchResultsController.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 02/06/2024.
//

import Foundation
import SwiftData

actor FetchResultsController<T>: ModelActor where T: LocalDatabaseModel {
    
    // MARK: Properties
    
    nonisolated var modelExecutor: any ModelExecutor { _modelExecutor }
    nonisolated var modelContainer: ModelContainer { _modelContainer }
    
    // MARK: Private properties
    
    private let _modelExecutor: any ModelExecutor
    private let _modelContainer: ModelContainer
    private let localDatabaseDataSource: LocalDatabaseDataStoreProtocol
    private let predicate: Predicate<T>?
    private let sortDescriptors: [SortDescriptor<T>]
    private var baseFetchedModels: [T] = []
    
    // MARK: Properties
    
    private(set) var fetchedModels: [T] = []
    
    // MARK: Lifecycle
    
    init(
        predicate: Predicate<T>? = nil,
        sortDescriptors: [SortDescriptor<T>] = [],
        localDatabaseDataSource: LocalDatabaseDataStoreProtocol,
        modelContainer: ModelContainer,
        modelExecutor: any ModelExecutor
    ) {
        self.predicate = predicate
        self.sortDescriptors = sortDescriptors
        self.localDatabaseDataSource = localDatabaseDataSource
        self._modelContainer = modelContainer
        self._modelExecutor = modelExecutor
    }
    
    // MARK: Methods
    
    func fetchStream() async throws -> AsyncThrowingStream<[T], Error> {
        do {
            let fetchedModels = try await localDatabaseDataSource.fetch(
                object: T.self,
                predicate: predicate,
                sorts: sortDescriptors
            )
            
            self.fetchedModels = fetchedModels
        } catch {
            Logger.error("Creating fetch stream for object: \(String(describing: T.self)) failed with error:\n\(error)")
            throw error
        }
        
        return AsyncThrowingStream { continuation in
            Task { [weak self] in
                await self?.observeLocalDatabaseChanges { models in
                    continuation.yield(with: .success(models))
                }
            }
            
            Task { [weak self] in
                await self?.observeLocalDatabaseSave(resultBlock: { result in
                    continuation.yield(with: result)
                })
            }
        }
    }
    
    // MARK: Private methods
    
    private func observeLocalDatabaseChanges(successBlock: @Sendable @escaping ([T]) -> ()) async {
        for await _ in NotificationCenter.default.notifications(named: .persistentModelDidChange).map({ $0.name }) {
            let insertedModels: [T] = await localDatabaseDataSource.getInsertedModels()
            let deletedModels: [T] = await localDatabaseDataSource.getDeletedModels()
            
            var models = self.baseFetchedModels
            
            for i in 0..<models.count where deletedModels.contains(models[i]) {
                models.remove(at: i)
            }
            
            for insertedModel in insertedModels where !models.contains(insertedModel) {
                models.append(insertedModel)
            }
            
            models.sort(using: sortDescriptors)
            
            fetchedModels = models
            
            successBlock(models)
        }
    }
    
    private func observeLocalDatabaseSave(resultBlock: @Sendable @escaping (Result<[T], Error>) -> ()) async {
        for await _ in NotificationCenter.default.notifications(named: .persistentModelDidSave).map({ $0.name }) {
            do {
                let models = try await localDatabaseDataSource.fetch(
                    object: T.self,
                    predicate: predicate,
                    sorts: sortDescriptors
                )
                
                baseFetchedModels = models
                resultBlock(.success(models))
            } catch {
                resultBlock(.failure(error))
            }
        }
    }
}
