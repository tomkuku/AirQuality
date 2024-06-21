//
//  LocalDatabaseFetchResultsRepositoryTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 05/06/2024.
//

import XCTest
import SwiftData

@testable import AirQuality

final class LocalDatabaseFetchResultsRepositoryTests: BaseTestCase, @unchecked Sendable {
    
    private var sut: LocalDatabaseFetchResultsRepository<LocalDatabaseMapperSpy>!
    
    private var localDatabaseFetchResultsDataSourceSpy: LocalDatabaseFetchResultsDataSourceSpy<LocalDatabaseModelDummy>!
    private var mapperSpy: LocalDatabaseMapperSpy!
    private var modelContainerSpy: ModelContainerSpy!
    
    private var streamedObjects: [DomainModelDummy]!
    
    override func setUp() {
        super.setUp()
        
        DependenciesContainerManager.container = appDependencies
        
        modelContainerSpy = ModelContainerSpy(schemeModels: [LocalDatabaseModelDummy.self])
        
        localDatabaseFetchResultsDataSourceSpy = .init()
        mapperSpy = LocalDatabaseMapperSpy()
        
        sut = LocalDatabaseFetchResultsRepository(
            localDatabaseFetchResultsDataSource: localDatabaseFetchResultsDataSourceSpy,
            mapper: mapperSpy
        )
    }
    
    func testCreateNewStream() async {
        // Given
        let domainModel1 = DomainModelDummy(id: 1)
        let domainModel2 = DomainModelDummy(id: 2)
        
        let localDatabaseModel1 = LocalDatabaseModelDummy(identifier: 1)
        let localDatabaseModel2 = LocalDatabaseModelDummy(identifier: 2)
        
        mapperSpy.mapToDomainModelReturnValueClosure = { model in
            if model.persistentModelID == localDatabaseModel1.persistentModelID {
                domainModel1
            } else {
                domainModel2
            }
        }
        
        localDatabaseFetchResultsDataSourceSpy.streamResultClosure = .success([localDatabaseModel1, localDatabaseModel2])
        
        // When
        tasks.append( Task {
            for try await objests in sut.ceateNewStrem() {
                streamedObjects = objests
                expectation.fulfill()
            }
        })
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(streamedObjects, [domainModel1, domainModel2])
    }
    
    func testFetchedObjects() async throws {
        // Given
        let domainModel1 = DomainModelDummy(id: 1)
        let domainModel2 = DomainModelDummy(id: 2)
        
        let localDatabaseModel1 = LocalDatabaseModelDummy(identifier: 1)
        let localDatabaseModel2 = LocalDatabaseModelDummy(identifier: 2)
        
        mapperSpy.mapToDomainModelReturnValueClosure = { model in
            if model.persistentModelID == localDatabaseModel1.persistentModelID {
                domainModel1
            } else {
                domainModel2
            }
        }
        
        localDatabaseFetchResultsDataSourceSpy.fetchedModelsReturnValue = [localDatabaseModel1, localDatabaseModel2]
        
        // When
        let objects = try await sut.getFetchedObjects()
        
        // Then
        XCTAssertEqual(objects, [domainModel1, domainModel2])
    }
}

private final class LocalDatabaseFetchResultsDataSourceSpy<T>: LocalDatabaseFetchResultsDataSourceProtocol, @unchecked Sendable 
where T: LocalDatabaseModel {
    typealias FetchModel = T
    
    var fetchedModelsReturnValue: [T] = []
    var streamResultClosure: Result<[T], Error>?
    
    var fetchedModels: [T] {
        fetchedModelsReturnValue
    }
    
    func createNewStrem() async throws -> AsyncThrowingStream<[T], any Error> {
        AsyncThrowingStream { continuation in
            switch streamResultClosure {
            case .success(let models):
                continuation.yield(models)
            case .failure(let error):
                continuation.yield(with: .failure(error))
            case .none:
                break
            }
        }
    }
}
