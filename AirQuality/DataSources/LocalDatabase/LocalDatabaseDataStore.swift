//
//  LocalDatabaseDataStore.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 27/05/2024.
//

import Foundation
import SwiftData
import class UIKit.UIScene

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

actor LocalDatabaseDataStore: ModelActor, LocalDatabaseDataStoreProtocol {
    
    // MARK: Properties
    
    nonisolated let modelExecutor: any ModelExecutor
    nonisolated let modelContainer: ModelContainer
    
    // MARK: Private properties
    
    private let modelContext: ModelContext
    private let backgroundTasksManager: BackgroundTasksManagerProtocol
    
    // MARK: Lifecycle
    
    init(
        modelContainer: ModelContainer,
        backgroundTasksManager: BackgroundTasksManagerProtocol
    ) {
        self.modelContext = ModelContext(modelContainer)
        modelContext.autosaveEnabled = false
        self.modelContainer = modelContainer
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: modelContext)
        self.backgroundTasksManager = backgroundTasksManager
        
        Task { @MainActor [weak self] in
            await self?.observeSceneStates()
        }
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
        guard modelContext.hasChanges else { return }
        
        do {
            try modelContext.save()
            
            Task.detached {
                NotificationCenter.default.post(name: .persistentModelDidSave, object: nil)
            }
        } catch {
            Logger.error("Saving context failed with error: \(error.localizedDescription)")
        }
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
    
    @MainActor
    private func observeSceneStates() async {
        for await _ in NotificationCenter.default.notifications(named: UIScene.willDeactivateNotification).map({ $0.name }) {
            backgroundTasksManager.beginFiniteLengthTask()
            
            try? await save()
            
            backgroundTasksManager.endFiniteLengthTask()
        }
    }
}
