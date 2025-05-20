//
//  LocalDatabaseDataSourceSpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 05/06/2024.
//

import Foundation
import SwiftData

@testable import AirQuality

actor LocalDatabaseDataSourceSpy: LocalDatabaseDataSourceProtocol {
    enum Event: Sendable, Equatable {
        case getInsertedModels
        case getDeletedModels
        case insert(PersistentIdentifier)
        case delete(PersistentIdentifier)
        case fetch
    }
    
    var events: [Event] = []
    
    private var insertedModelsReturnValue: [any LocalDatabaseModel] = []
    private var deletedModelsReturnValue: [any LocalDatabaseModel] = []
    private var fetchReturnValue: [any LocalDatabaseModel] = []
    
    func setInsertedModelsReturnValue(models: [any LocalDatabaseModel]) {
        insertedModelsReturnValue = models
    }
    
    func setGetDeletedModelsReturnValue(models: [any LocalDatabaseModel]) {
        deletedModelsReturnValue = models
    }
    
    func setFetchReturnValue(models: [any LocalDatabaseModel]) {
        fetchReturnValue = models
    }
    
    func deleteAllEvents() {
        events.removeAll()
    }
    
    // MARK: LocalDatabaseDataSourceProtocol
    
    func getInsertedModels<T>() -> [T] where T: PersistentModel {
        events.append(.getInsertedModels)
        return insertedModelsReturnValue.compactMap { $0 as? T }
    }
    
    func getDeletedModels<T>() -> [T] where T: PersistentModel {
        events.append(.getDeletedModels)
        return deletedModelsReturnValue.compactMap { $0 as? T }
    }
    
    func insert<T>(_ model: T) where T: PersistentModel {
        events.append(.insert(model.persistentModelID))
    }
    
    func delete<T>(_ model: T) where T: PersistentModel {
        events.append(.delete(model.persistentModelID))
    }
    
    func fetch<T>(
        object: T.Type,
        predicate: Predicate<T>?,
        sorts: [SortDescriptor<T>],
        fetchLimit: Int?
    ) throws -> [T] where T: PersistentModel {
        events.append(.fetch)
        return fetchReturnValue.compactMap { $0 as? T }
    }
}
