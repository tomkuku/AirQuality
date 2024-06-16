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
}
