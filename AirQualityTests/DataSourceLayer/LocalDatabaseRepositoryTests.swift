//
//  LocalDatabaseRepositoryTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 05/06/2024.
//

import XCTest
import SwiftData

@testable import AirQuality

final class LocalDatabaseRepositoryTests: BaseTestCase {
    
    private var sut: LocalDatabaseRepository!
    private var localDatabaseDataSourceSpy: LocalDatabaseDataSourceSpy!
    private var modelContainerSpy: ModelContainer!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
    
        let schema = Schema([LocalDatabaseModelDummy.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainerSpy = try ModelContainer(for: schema, configurations: [configuration])
        
        localDatabaseDataSourceSpy = LocalDatabaseDataSourceSpy()

        sut = LocalDatabaseRepository(localDatabaseDataSource: localDatabaseDataSourceSpy)
    }
    
    override func setUp() {
        super.setUp()
    
        DependenciesContainerManager.container = appDependencies
    }
    
    // MARK: Insert
    
    func testInsert() async throws {
        // Given
        let domainModel = DomainModelDummy()
        let dbModel = LocalDatabaseModelDummy(identifier: 1)
        
        let mapper = LocalDatabaseMapperSpy()
        mapper.mapToDatabaseModelReturnValueClosure = { _ in
            dbModel
        }
        
        mapper.mapToDomainModelReturnValueClosure = { _ in
            domainModel
        }
        
        // When
        try await sut.insert(mapper: mapper, object: domainModel)
        
        // Then
        let localDatabaseDataSourceEvents = await localDatabaseDataSourceSpy.events
        XCTAssertEqual(localDatabaseDataSourceEvents, [.insert(dbModel.persistentModelID)])
    }
    
    // MARK: Delete
    
    func testDeleteWhenObjectHasBeenInserted() async throws {
        // Given
        let domainModel = DomainModelDummy()
        let dbModel = LocalDatabaseModelDummy(identifier: 1)
        
        let mapper = LocalDatabaseMapperSpy()
        mapper.mapToDatabaseModelReturnValueClosure = { _ in
            dbModel
        }
        
        mapper.mapToDomainModelReturnValueClosure = { _ in
            domainModel
        }
        
        await localDatabaseDataSourceSpy.setFetchReturnValue(models: [dbModel])
        
        // When
        try await sut.delete(mapperType: LocalDatabaseMapperSpy.self, object: domainModel)
        
        // Then
        let localDatabaseDataSourceEvents = await localDatabaseDataSourceSpy.events
        XCTAssertEqual(localDatabaseDataSourceEvents, [.fetch, .delete(dbModel.persistentModelID)])
    }
    
    func testDeleteWhenObjectHasNotBeenInserted() async throws {
        // Given
        let domainModel = DomainModelDummy()
        let dbModel = LocalDatabaseModelDummy(identifier: 1)
        
        let mapper = LocalDatabaseMapperSpy()
        mapper.mapToDatabaseModelReturnValueClosure = { _ in
            dbModel
        }
        
        mapper.mapToDomainModelReturnValueClosure = { _ in
            domainModel
        }
        
        // When
        try await sut.delete(mapperType: LocalDatabaseMapperSpy.self, object: domainModel)
        
        // Then
        let localDatabaseDataSourceEvents = await localDatabaseDataSourceSpy.events
        XCTAssertEqual(localDatabaseDataSourceEvents, [.fetch])
    }
    
//    final class StationsLocalDatabaseMapperSpy: StationsLocalDatabaseMapperProtocol, @unchecked Sendable {
//        var mapToDomainModelReturnValue: Station!
//        var mapToDatabaseModelReturnValue: StationLocalDatabaseModel!
//        
//        required init() { }
//        
//        func map(_ input: StationLocalDatabaseModel) throws -> Station {
//            mapToDomainModelReturnValue
//        }
//        
//        func mapDomainModel(_ input: Station) throws -> StationLocalDatabaseModel {
//            mapToDatabaseModelReturnValue
//        }
//    }
//  
//    private class LocalDatabaseMapperSpy<DomainModel, DBModel>: LocalDatabaseMapperProtocol, @unchecked Sendable
//    where DomainModel: Identifiable, DBModel: LocalDatabaseModel, DomainModel.ID == DBModel.IdentifierType {
//        
//        var mapToDomainModelReturnValue: DomainModel!
//        var mapToDatabaseModelReturnValue: DBModel!
//        
//        required init() { }
//        
//        func map(_ input: DBModel) throws -> DomainModel {
//            mapToDomainModelReturnValue
//        }
//        
//        func mapDomainModel(_ input: DomainModel) throws -> DBModel {
//            mapToDatabaseModelReturnValue
//        }
//    }
}

//final class FetchedModelsController<T>: FetchedModelsControllerProtocol, @unchecked Sendable where T: LocalDatabaseModel {
//    
//    typealias FetchModel = T
//    
//    var fetchedModelsResultValue: [FetchModel] = []
//    var createNewStreamReturnValue: Result<[FetchModel], any Error>?
//    
//    var fetchedModels: [FetchModel] {
//        fetchedModelsResultValue
//    }
//    
//    func createNewStrem() async throws -> AsyncThrowingStream<[FetchModel], any Error> {
//        AsyncThrowingStream { [weak self] continuation in
//            guard let result = self?.createNewStreamReturnValue else { return }
//            
//            continuation.yield(with: result)
//        }
//    }
//}
