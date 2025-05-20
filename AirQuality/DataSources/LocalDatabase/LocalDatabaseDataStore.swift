//
//  LocalDatabaseDataSource.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 27/05/2024.
//

import Foundation
import SwiftData
import class UIKit.UIScene

protocol LocalDatabaseDataSourceProtocol: AnyObject, Actor {
    func getInsertedModels<T>() -> [T] where T: PersistentModel
    func getDeletedModels<T>() -> [T] where T: PersistentModel
    
    func insert<T>(_ model: T) where T: PersistentModel
    func delete<T>(_ model: T) where T: PersistentModel
    
    func fetch<T>(
        object: T.Type,
        predicate: Predicate<T>?,
        sorts: [SortDescriptor<T>],
        fetchLimit: Int?
    ) throws -> [T] where T: PersistentModel
}

extension LocalDatabaseDataSourceProtocol {
    func fetch<T>(
        object: T.Type,
        predicate: Predicate<T>? = nil,
        sorts: [SortDescriptor<T>] = []
    ) throws -> [T] where T: PersistentModel {
        try self.fetch(
            object: object,
            predicate: predicate,
            sorts: sorts,
            fetchLimit: nil
        )
    }
    
    func fetchFirst<T>(
        object: T.Type,
        predicate: Predicate<T>? = nil,
        sorts: [SortDescriptor<T>] = []
    ) throws -> T? where T: PersistentModel {
        try self.fetch(
            object: object,
            predicate: predicate,
            sorts: sorts,
            fetchLimit: 1
        )
        .first
    }
}

actor LocalDatabaseDataSource: ModelActor, LocalDatabaseDataSourceProtocol {
    
    // MARK: Properties
    
    nonisolated let modelExecutor: any ModelExecutor
    nonisolated let modelContainer: ModelContainer
    
    // MARK: Private properties
    
    private let modelContext: ModelContext
    private let backgroundTasksManager: BackgroundTasksManagerProtocol
    private let notificationCenter: NotificationCenterProtocol
    
    // MARK: Lifecycle
    
    init(
        modelContainer: ModelContainer,
        backgroundTasksManager: BackgroundTasksManagerProtocol,
        notificationCenter: NotificationCenterProtocol
    ) {
        self.modelContext = ModelContext(modelContainer)
        modelContext.autosaveEnabled = false
        self.modelContainer = modelContainer
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: modelContext)
        self.backgroundTasksManager = backgroundTasksManager
        self.notificationCenter = notificationCenter
        
        observeSceneStates()
    }
    
    // MARK: Methods
    
    func getInsertedModels<T>() -> [T] where T: PersistentModel {
        modelContext.insertedModelsArray.compactMap({ $0 as? T })
    }
    
    func getDeletedModels<T>() -> [T] where T: PersistentModel {
        modelContext.deletedModelsArray.compactMap({ $0 as? T })
    }
    
    func insert<T>(_ model: T) where T: PersistentModel {
        modelContext.insert(model)
        
        Task.detached {
            NotificationCenter.default.post(name: .localDatabaseDidChange, object: self)
        }
    }
    
    func delete<T>(_ model: T) where T: PersistentModel {
        modelContext.delete(model)
        
        Task.detached {
            NotificationCenter.default.post(name: .localDatabaseDidChange, object: self)
        }
    }
    
    func fetch<T>(
        object: T.Type,
        predicate: Predicate<T>?,
        sorts: [SortDescriptor<T>],
        fetchLimit: Int?
    ) throws -> [T] where T: PersistentModel {
        var fetchDescriptor = FetchDescriptor(predicate: predicate, sortBy: sorts)
        fetchDescriptor.fetchLimit = fetchLimit
        
        return try modelContext.fetch(fetchDescriptor)
    }
    
    // MARK: Privte methods
    
    func save() throws {
        guard modelContext.hasChanges else { return }
        
        do {
            try modelContext.save()
            
            notificationCenter.post(name: .localDatabaseDidSave, object: self)
        } catch {
            Logger.error("Saving context failed with error: \(error.localizedDescription)")
        }
    }
    
    private nonisolated func observeSceneStates() {
        Task { [weak self] in
            guard let self else { return }
            
            for await _ in self.notificationCenter.notifications(named: UIScene.willDeactivateNotification).map({ $0.name }) {
                await self.backgroundTasksManager.beginFiniteLengthTask()
                
                try? await self.save()
                
                await self.backgroundTasksManager.endFiniteLengthTask()
            }
        }
    }
}
