//
//  LocalDatabaseDataStore.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 27/05/2024.
//

import Foundation
import SwiftData
import Combine

protocol LocalDatabaseDataStoreProtocol: Sendable, Actor {
    func insert<T>(_ model: T) async where T: PersistentModel & Sendable
    
    func delete<T>(_ model: T) async where T: PersistentModel & Sendable
    
    func fetch<T>(
        _ fetchDescription: FetchDescriptor<T>
    ) async throws -> [T] where T: PersistentModel & Sendable
    
    func fetchStream<T>(
        fetchDescriptor: FetchDescriptor<T>
    ) async -> AsyncThrowingStream<[T], Error> where T: PersistentModel & Sendable
}

@ModelActor
actor LocalDatabaseDataStore: LocalDatabaseDataStoreProtocol {
    private lazy var modelContext: ModelContext = {
        let context = ModelContext(modelContainer)
        context.autosaveEnabled = false
        return context
    }()
    
    private let contextDidChangeSubject = PassthroughSubject<Void, Never>()
    private let contextDidSaveSubject = PassthroughSubject<Void, Never>()
    
    func insert<T>(_ model: T) async where T: PersistentModel & Sendable {
        modelContext.insert(model)
        
        contextDidChangeSubject.send()
        NotificationCenter.default.post(name: .persistentModelDidChange, object: modelContext)
    }
    
    func delete<T>(_ model: T) async where T: PersistentModel & Sendable {
        modelContext.delete(model)
        
        contextDidChangeSubject.send()
        NotificationCenter.default.post(name: .persistentModelDidChange, object: modelContext)
    }
    
    func save() throws {
        do {
            try modelContext.save()
            contextDidSaveSubject.send()
            NotificationCenter.default.post(name: .persistentModelDidSave, object: modelContext)
        } catch {
            throw error
        }
    }
    
    func fetch<T>(
        _ fetchDescription: FetchDescriptor<T>
    ) async throws -> [T] where T: PersistentModel & Sendable {
        try modelContext.fetch(fetchDescription)
    }
    
    func fetchStream<T>(
        fetchDescriptor: FetchDescriptor<T>
    ) async -> AsyncThrowingStream<[T], Error> where T: PersistentModel & Sendable {
        AsyncThrowingStream { continuation in
            Task { [weak contextDidChangeSubject, weak contextDidSaveSubject] in
                guard let contextDidChangeSubject, let contextDidSaveSubject else { return }
                
                for await _ in AsyncPublisher(contextDidChangeSubject.eraseToAnyPublisher()) {
                    let insertedModels = modelContext.insertedModelsArray
                    let deletedModels = modelContext.deletedModelsArray
                    let changedModels = modelContext.changedModelsArray
                    
                    let models: [T] = [insertedModels, deletedModels, changedModels]
                        .flatMap { $0 }
                        .reduce(into: []) { partialResult, persistentModel in
                            guard let model = persistentModel as? T else { return }
                            
                            partialResult.append(model)
                        }
                        .sorted(using: fetchDescriptor.sortBy)
                    
                    continuation.yield(with: .success(models))
                }
            }
            
            Task {
                for await _ in AsyncPublisher(contextDidSaveSubject) {
                    do {
                        let models = try modelContext.fetch(fetchDescriptor)
                        continuation.yield(models)
                    } catch {
                        continuation.yield(with: .failure(error))
                    }
                }
            }
        }
    }
}

extension FetchDescriptor: @unchecked Sendable { }
