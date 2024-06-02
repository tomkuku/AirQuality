//
//  LocalDatabaseDataStore.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 27/05/2024.
//

import Foundation
import SwiftData
import Combine

protocol LocalDatabaseDataStoreProtocol: Sendable, AnyObject {
    func getInsertedModels<T>() async -> [T] where T: LocalDatabaseModel
    func getDeletedModels<T>() async -> [T] where T: LocalDatabaseModel
    
    func insert<T>(_ model: T) async where T: LocalDatabaseModel
    func delete<T>(_ model: T) async where T: LocalDatabaseModel
    
    func fetch<T>(
        object: T.Type,
        predicate: Predicate<T>?,
        sorts: [SortDescriptor<T>],
        fetchLimit: Int?
    ) async throws -> [T] where T: LocalDatabaseModel
}

extension LocalDatabaseDataStoreProtocol {
    func fetch<T>(
        object: T.Type,
        predicate: Predicate<T>? = nil,
        sorts: [SortDescriptor<T>] = [],
        fetchLimit: Int? = nil
    ) async throws -> [T] where T: LocalDatabaseModel {
        try await fetch(
            object: object,
            predicate: predicate,
            sorts: sorts,
            fetchLimit: fetchLimit
        )
    }
    
    func fetchFirst<T>(
        object: T.Type,
        predicate: Predicate<T>? = nil,
        sorts: [SortDescriptor<T>] = []
    ) async throws -> T? where T: LocalDatabaseModel {
        try await fetch(
            object: object,
            predicate: predicate,
            sorts: sorts,
            fetchLimit: 1
        )
        .first
    }
}

@ModelActor
actor LocalDatabaseDataStore: LocalDatabaseDataStoreProtocol {
    
    // MARK: Properties
    
    nonisolated var modelExecutor: any ModelExecutor { _modelExecutor }
    nonisolated var modelContainer: ModelContainer { _modelContainer }
    
    // MARK: Private properties
    
    private let modelContext: ModelContext
    private let _modelExecutor: any ModelExecutor
    private let _modelContainer: ModelContainer
    
    // MARK: Lifecycle
    
    init(
        modelContainer: ModelContainer
    ) {
        self.modelContext = ModelContext(modelContainer)
        modelContext.autosaveEnabled = false
        self._modelContainer = modelContainer
        let defaultSerialModelExecutor = DefaultSerialModelExecutor(modelContext: modelContext)
        self._modelExecutor = defaultSerialModelExecutor
    }
    
    // MARK: Methods
    
    func getInsertedModels<T>() async -> [T] where T: LocalDatabaseModel {
        modelContext.insertedModelsArray.compactMap({ $0 as? T })
    }
    
    func getDeletedModels<T>() async -> [T] where T: LocalDatabaseModel {
        modelContext.deletedModelsArray.compactMap({ $0 as? T })
    }
    
    func insert<T>(_ model: T) async where T: LocalDatabaseModel {
        modelContext.insert(model)
        
        Task.detached {
            NotificationCenter.default.post(name: .persistentModelDidChange, object: nil)
        }
    }
    
    func delete<T>(_ model: T) async where T: LocalDatabaseModel {
        modelContext.delete(model)
        
        Task.detached {
            NotificationCenter.default.post(name: .persistentModelDidChange, object: nil)
        }
    }
    
    func save() throws {
        try modelContext.save()
    }
    
    func fetch<T>(
        object: T.Type,
        predicate: Predicate<T>?,
        sorts: [SortDescriptor<T>],
        fetchLimit: Int?
    ) async throws -> [T] where T: LocalDatabaseModel {
        var fetchDescriptor = FetchDescriptor(predicate: predicate, sortBy: sorts)
        fetchDescriptor.fetchLimit = fetchLimit
        
        return try modelContext.fetch(fetchDescriptor)
    }
    
    // MARK: Privaet methods
    
    private func observeNotifications() {
        Task {
            for await _ in NotificationCenter.default.notifications(named: ModelContext.didSave, object: modelContext).map({ $0.name }) {
                NotificationCenter.default.post(name: .persistentModelDidSave, object: self)
            }
        }
    }
}
