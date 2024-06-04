//
//  FetchedModelsController.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 02/06/2024.
//

import Foundation
import SwiftData
import Combine

protocol FetchedModelsControllerProtocol<FetchModel>: Sendable {
    associatedtype FetchModel: LocalDatabaseModel
    
    var fetchedModels: [FetchModel] { get async }
    
    func createNewStrem() async throws -> AsyncThrowingStream<[FetchModel], Error>
}

actor FetchedModelsController<T>: FetchedModelsControllerProtocol, Sendable where T: LocalDatabaseModel {
    
    typealias FetchModel = T
    
    // MARK: Properties
    
    nonisolated let modelExecutor: any ModelExecutor
    nonisolated let modelContainer: ModelContainer
    
    // MARK: Private properties
    
    private let localDatabaseDataSource: LocalDatabaseDataSourceProtocol
    private let predicate: Predicate<T>?
    private let sortDescriptors: [SortDescriptor<T>]
    private let subject = CurrentValueSubject<[T], Error>([])
    private let fetchedModelsPublisher: AsyncThrowingPublisher<AnyPublisher<[T], Error>>
    private var cancellable = Set<AnyCancellable>()
    private var hasStarted = false
    private let notificationCenter: NotificationCenterProtocol
    
    private var baseFetchedModels: [T] = [] {
        didSet {
            subject.send(baseFetchedModels)
        }
    }
    
    // MARK: Properties
    
    var fetchedModels: [FetchModel] {
        get async {
            subject.value
        }
    }
    
    // MARK: Lifecycle
    
    init(
        predicate: Predicate<T>? = nil,
        sortDescriptors: [SortDescriptor<T>] = [],
        localDatabaseDataSource: LocalDatabaseDataSourceProtocol,
        modelContainer: ModelContainer,
        modelExecutor: any ModelExecutor,
        notificationCenter: NotificationCenterProtocol
    ) {
        self.predicate = predicate
        self.sortDescriptors = sortDescriptors
        self.localDatabaseDataSource = localDatabaseDataSource
        self.modelContainer = modelContainer
        self.modelExecutor = modelExecutor
        self.fetchedModelsPublisher = .init(subject.eraseToAnyPublisher())
        self.notificationCenter = notificationCenter
    }
    
    // MARK: Methods
    
    func createNewStrem() async throws -> AsyncThrowingStream<[T], Error> {
        if !hasStarted {
            do {
                hasStarted = true
                try await start()
            } catch {
                hasStarted = false
                throw error
            }
        }
        
        return AsyncThrowingStream { continuation in
            subject
                .asyncSink(receiveCompletion: {
                    guard case .failure(let error) = $0 else { return }
                    continuation.finish(throwing: error)
                }, receiveValue: {
                    continuation.yield($0)
                })
                .store(in: &cancellable)
        }
    }
    
    // MARK: Private methods
    
    private func start() async throws {
        baseFetchedModels = try await localDatabaseDataSource.fetch(
            object: T.self,
            predicate: predicate,
            sorts: sortDescriptors
        )
        
        Task { [weak self] in
            await self?.observeLocalDatabaseChanges()
        }
        
        Task { [weak self] in
            await self?.observeLocalDatabaseSave()
        }
    }
    
    private func observeLocalDatabaseChanges() async {
        for await _ in notificationCenter.notifications(named: .localDatabaseDidChange, object: localDatabaseDataSource).map({ $0.name }) {
            let insertedModels: [T] = await localDatabaseDataSource.getInsertedModels()
            let deletedModels: [T] = await localDatabaseDataSource.getDeletedModels()
            
            var models = self.baseFetchedModels
            
            for insertedModel in insertedModels where !models.contains(insertedModel) {
                models.append(insertedModel)
            }
            
            for (i, model) in models.enumerated() where deletedModels.contains(model) {
                models.remove(at: i)
            }
            
            models.sort(using: sortDescriptors)
            
            subject.send(models)
        }
    }
    
    private func observeLocalDatabaseSave() async {
        for await _ in notificationCenter.notifications(named: .localDatabaseDidSave, object: localDatabaseDataSource).map({ $0.name }) {
            do {
                let models = try await localDatabaseDataSource.fetch(
                    object: T.self,
                    predicate: predicate,
                    sorts: sortDescriptors
                )
                
                print("[LL] fetch 2")
                
                baseFetchedModels = models
            } catch {
                subject.send(completion: .failure(error))
            }
        }
    }
}
