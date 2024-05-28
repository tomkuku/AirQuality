//
//  LocalDatabaseDataStore.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 27/05/2024.
//

import Foundation
import SwiftData

protocol LocalDatabaseDataStoreProtocol: Sendable {
    func insert<T: Sendable>(_ model: T) async where T: PersistentModel & Sendable
    
    func fetch<T>(
        _ fetchDescription: FetchDescriptor<T>
    ) async throws -> [T] where T: PersistentModel & Sendable
}

@ModelActor
final actor LocalDatabaseDataStore: LocalDatabaseDataStoreProtocol {
    private lazy var modelContext: ModelContext = {
        ModelContext(modelContainer)
    }()
    
    func insert<T>(_ model: T) async where T: PersistentModel & Sendable {
        modelContext.insert(model)
    }
    
    func fetch<T>(
        _ fetchDescription: FetchDescriptor<T>
    ) async throws -> [T] where T: PersistentModel & Sendable {
        try modelContext.fetch(fetchDescription)
    }
}

extension FetchDescriptor: @unchecked Sendable { }
