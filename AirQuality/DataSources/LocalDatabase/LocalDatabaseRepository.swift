//
//  LocalDatabaseRepository.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 27/05/2024.
//

import Foundation
import SwiftData

protocol HasLocalDatabaseRepository {
    var localDatabaseRepository: LocalDatabaseRepositoryProtocol { get }
}

protocol LocalDatabaseRepositoryProtocol: Sendable {
    func insert<T, L>(mapper: T, object: L) async throws where T: LocalDatabaseMapperProtocol, L == T.DomainModel
    
    func delete<T, D>(
        mapperType: T.Type,
        object: D
    ) async throws where T: LocalDatabaseMapperProtocol, D == T.DomainModel
    
    func getFetchedStations() async throws -> [Station]
    
    func ceateObservedStationsStrem<T>(
        mapper: T
    ) -> AsyncThrowingStream<[Station], Error> where T: StationsLocalDatabaseMapperProtocol
}

final class LocalDatabaseRepository: LocalDatabaseRepositoryProtocol {
    
    private let localDatabaseDataSource: LocalDatabaseDataSourceProtocol
    private let stationsFetchedModelsController: any FetchedModelsControllerProtocol<StationLocalDatabaseModel>
    private let stationsLocalDatabaseMapper: any StationsLocalDatabaseMapperProtocol
    
    init(
        localDatabaseDataSource: LocalDatabaseDataSourceProtocol,
        stationsFetchedModelsController: FetchedModelsController<StationLocalDatabaseModel>,
        stationsLocalDatabaseMapper: any StationsLocalDatabaseMapperProtocol
    ) {
        self.localDatabaseDataSource = localDatabaseDataSource
        self.stationsFetchedModelsController = stationsFetchedModelsController
        self.stationsLocalDatabaseMapper = stationsLocalDatabaseMapper
    }
    
    func insert<T, L>(
        mapper: T,
        object: L
    ) async throws where T: LocalDatabaseMapperProtocol, L == T.DomainModel {
        let persistentModel = try mapper.mapDomainModel(object)
        
        await localDatabaseDataSource.insert(persistentModel)
    }
    
    func delete<T, D>(
        mapperType: T.Type,
        object: D
    ) async throws where T: LocalDatabaseMapperProtocol, D == T.DomainModel {
        let predicate = T.DTOModel.idPredicate(with: object.id)
        
        guard let fetchedObject = try await localDatabaseDataSource.fetchFirst(object: T.DTOModel.self, predicate: predicate) else {
            Logger.info("Object \(object) not found. Deletion is not possible!")
            return
        }
        
        await localDatabaseDataSource.delete(fetchedObject)
    }
    
    func getFetchedStations() async throws -> [Station] {
        try await stationsFetchedModelsController
            .fetchedModels
            .map {
                try stationsLocalDatabaseMapper.map($0)
            }
    }
    
    func ceateObservedStationsStrem<T>(
        mapper: T
    ) -> AsyncThrowingStream<[Station], Error> where T: StationsLocalDatabaseMapperProtocol {
        AsyncThrowingStream { continuation in
            Task { [weak self] in
                guard let self else { return }
                
                do {
                    for try await models in try await stationsFetchedModelsController.createNewStrem() {
                        let mappedModels = try models.map {
                            try mapper.map($0)
                        }
                        
                        continuation.yield(mappedModels)
                    }
                } catch {
                    continuation.yield(with: .failure(error))
                }
            }
        }
    }
}
