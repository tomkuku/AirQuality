//
//  LocalDatabaseDataStore.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 27/05/2024.
//

import Foundation
import SwiftData

protocol LocalDatabaseDataStoreProtocol {
    func insert<T>(_ model: T) where T: PersistentModel
    
    func fetch<T>(_ fetchDescription: FetchDescriptor<T>) throws -> [T] where T: PersistentModel
}

final class LocalDatabaseDataStore {
    let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func insert<T>(_ model: T) where T: PersistentModel {
        modelContext.insert(model)
    }
    
    func fetch<T>(_ fetchDescription: FetchDescriptor<T>
    ) throws -> [T] where T: PersistentModel {
        try modelContext.fetch(fetchDescription)
    }
}
