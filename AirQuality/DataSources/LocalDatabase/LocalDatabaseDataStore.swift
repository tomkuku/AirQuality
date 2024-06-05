//
//  LocalDatabaseDataSource.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 27/05/2024.
//

import Foundation
import SwiftData
import class UIKit.UIScene

protocol LocalDatabaseDataSourceProtocol: Sendable, AnyObject {
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

extension LocalDatabaseDataSourceProtocol {
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
        
        Task { [weak self] in
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
            NotificationCenter.default.post(name: .localDatabaseDidChange, object: self)
        }
    }
    
    func delete<T>(_ model: T) async where T: LocalDatabaseModel {
        modelContext.delete(model)
        
        Task.detached {
            NotificationCenter.default.post(name: .localDatabaseDidChange, object: self)
        }
    }
    
    func save() throws {
        guard modelContext.hasChanges else { return }
        
        do {
            try modelContext.save()
            
            notificationCenter.post(name: .localDatabaseDidSave, object: self)
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
    
    private func observeSceneStates() async {
        for await _ in await notificationCenter.notifications(named: UIScene.willDeactivateNotification).map({ $0.name }) {
            await backgroundTasksManager.beginFiniteLengthTask()
            
            try? save()
            
            await backgroundTasksManager.endFiniteLengthTask()
        }
    }
}
