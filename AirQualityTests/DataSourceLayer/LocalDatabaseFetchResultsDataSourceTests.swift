//
//  LocalDatabaseFetchResultsDataSourceTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 04/06/2024.
//

import XCTest
import SwiftData

@testable import AirQuality

final class LocalDatabaseFetchResultsDataSourceTests: BaseTestCase, @unchecked Sendable {
    
    private var sut: LocalDatabaseFetchResultsDataSource<LocalDatabaseModelDummy>!
    
    private var localDatabaseDataSourceSpy: LocalDatabaseDataSourceSpy!
    private var notificationCeneterSpy: NotificationCenterSpy!
    private var modelContextSpy: ModelContainerSpy!
    
    private var streamedObjects: [LocalDatabaseModelDummy]!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        localDatabaseDataSourceSpy = LocalDatabaseDataSourceSpy()
        
        notificationCeneterSpy = NotificationCenterSpy()
        
        modelContextSpy = ModelContainerSpy(schemeModels: [LocalDatabaseModelDummy.self])
        
        let modelContext = modelContextSpy.modelContext
        let modelExecutor = DefaultSerialModelExecutor(modelContext: modelContext)
        
        sut = .init(
            localDatabaseDataSource: localDatabaseDataSourceSpy,
            modelContainer: modelContextSpy.modelContainer,
            modelExecutor: modelExecutor,
            notificationCenter: notificationCeneterSpy
        )
        
        streamedObjects = []
    }
    
    override func setUp() {
        super.setUp()
        
        DependenciesContainerManager.container = appDependencies
    }
    
    func testCreateNewStream() async throws {
        // Given
        let model1 = LocalDatabaseModelDummy(identifier: 111)
        
        await localDatabaseDataSourceSpy.setFetchReturnValue(models: [model1])
        
        tasks.append(Task {
            // When
            do {
                for try await objects in try await sut.createNewStrem() {
                    streamedObjects = objects
                    expectation.fulfill()
                }
            } catch {
                XCTFail("Stream should not thown an error!")
            }
        })
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        var localDatabaseDataSourceSpyEvents = await localDatabaseDataSourceSpy.events
        XCTAssertEqual(localDatabaseDataSourceSpyEvents, [.fetch])
        XCTAssertEqual(Set(notificationCeneterSpy.events), Set([
            .publisher(.localDatabaseDidSave),
            .publisher(.localDatabaseDidChange)
        ]))
        
        XCTAssertEqual(streamedObjects, [model1])
        
        var fetchedModels = await sut.fetchedModels
        XCTAssertEqual(fetchedModels, [model1])
        
        // Given
        await localDatabaseDataSourceSpy.deleteAllEvents()
        expectation = XCTestExpectation(description: "com.local.database.did.save")
        
        let model2 = LocalDatabaseModelDummy(identifier: 222)
        
        await localDatabaseDataSourceSpy.setFetchReturnValue(models: [model1, model2])
        
        // When
        notificationCeneterSpy.notificationCenter.post(Notification(name: .localDatabaseDidSave, object: localDatabaseDataSourceSpy))
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        localDatabaseDataSourceSpyEvents = await localDatabaseDataSourceSpy.events
        XCTAssertEqual(localDatabaseDataSourceSpyEvents, [.fetch])
        XCTAssertEqual(streamedObjects, [model1, model2])
        
        fetchedModels = await sut.fetchedModels
        XCTAssertEqual(fetchedModels, [model1, model2])
        
        // Given
        await localDatabaseDataSourceSpy.deleteAllEvents()
        expectation = XCTestExpectation(description: "com.local.database.did.change")
        
        let model3 = LocalDatabaseModelDummy(identifier: 333)
        
        await localDatabaseDataSourceSpy.setInsertedModelsReturnValue(models: [model3])
        await localDatabaseDataSourceSpy.setGetDeletedModelsReturnValue(models: [model1])
        
        // When
        notificationCeneterSpy.notificationCenter.post(Notification(name: .localDatabaseDidChange, object: localDatabaseDataSourceSpy))
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        localDatabaseDataSourceSpyEvents = await localDatabaseDataSourceSpy.events
        XCTAssertEqual(localDatabaseDataSourceSpyEvents, [.getInsertedModels, .getDeletedModels])
        XCTAssertEqual(streamedObjects, [model2, model3])
        
        fetchedModels = await sut.fetchedModels
        XCTAssertEqual(fetchedModels, [model2, model3])
    }
    
    func testCreateNewStreamWhenOtherStreamHasAlreadyBeenCreated() async throws {
        // Given
        expectation.expectedFulfillmentCount = 2
        
        let streamsWrapper = StreamsWrapper()
        let model1 = LocalDatabaseModelDummy(identifier: 111)
        
        await localDatabaseDataSourceSpy.setFetchReturnValue(models: [model1])
        
        // When
        tasks.append(Task {
            do {
                for try await models in try await sut.createNewStrem() {
                    await streamsWrapper.setStreamedModels1(models)
                    expectation.fulfill()
                }
            } catch {
                XCTFail("Stream should not thown an error!")
            }
        })
        
        tasks.append(Task {
            do {
                for try await models in try await sut.createNewStrem() {
                    await streamsWrapper.setStreamedModels2(models)
                    expectation.fulfill()
                }
            } catch {
                XCTFail("Stream should not thown an error!")
            }
        })
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        var localDatabaseDataSourceSpyEvents = await localDatabaseDataSourceSpy.events
        XCTAssertEqual(localDatabaseDataSourceSpyEvents, [.fetch])
        
        var streamedModels1 = await streamsWrapper.streamedModels1
        var streamedModels2 = await streamsWrapper.streamedModels2
        XCTAssertEqual(streamedModels1, [model1])
        XCTAssertEqual(streamedModels2, [model1])
        XCTAssertEqual(Set(notificationCeneterSpy.events), Set([
            .publisher(.localDatabaseDidSave),
            .publisher(.localDatabaseDidChange)
        ]))
        
        // Given
        expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2
        
        await localDatabaseDataSourceSpy.deleteAllEvents()
        
        let model2 = LocalDatabaseModelDummy(identifier: 222)
        
        await localDatabaseDataSourceSpy.setInsertedModelsReturnValue(models: [model2])
        
        // When
        notificationCeneterSpy.notificationCenter.post(Notification(name: .localDatabaseDidChange, object: localDatabaseDataSourceSpy))
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        localDatabaseDataSourceSpyEvents = await localDatabaseDataSourceSpy.events
        XCTAssertEqual(localDatabaseDataSourceSpyEvents, [.getInsertedModels, .getDeletedModels])
        
        streamedModels1 = await streamsWrapper.streamedModels1
        streamedModels2 = await streamsWrapper.streamedModels2
        XCTAssertEqual(streamedModels1, [model1, model2])
        XCTAssertEqual(streamedModels2, [model1, model2])
        XCTAssertEqual(Set(notificationCeneterSpy.events), Set([
            .publisher(.localDatabaseDidSave),
            .publisher(.localDatabaseDidChange)
        ]))
    }
    
    // MARK: StreamsWrapper
    
    private actor StreamsWrapper {
        var streamedModels1: [LocalDatabaseModelDummy] = []
        var streamedModels2: [LocalDatabaseModelDummy] = []
        
        func setStreamedModels1(_ models: [LocalDatabaseModelDummy]) {
            streamedModels1 = models
        }
        
        func setStreamedModels2(_ models: [LocalDatabaseModelDummy]) {
            streamedModels2 = models
        }
    }
}
