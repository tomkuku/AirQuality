//
//  LocalDatabaseDataSourceTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 03/06/2024.
//

import XCTest
import SwiftData
import class UIKit.UIScene

@testable import AirQuality

final class LocalDatabaseDataSourceTests: BaseTestCase, @unchecked Sendable {
    private var sut: LocalDatabaseDataSource!
    
    private var backgroundTasksManagerSpy: BackgroundTasksManagerSpy!
    private var modelContainerSpy: ModelContainerSpy!
    private var modelContextSpy: ModelContext?
    private var notificationCenterDummy: NotificationCenter!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        modelContainerSpy = ModelContainerSpy(schemeModels: [LocalDatabaseModelDummy.self])
        modelContextSpy = modelContainerSpy.modelContext
        
        backgroundTasksManagerSpy = BackgroundTasksManagerSpy()
        
        notificationCenterDummy = NotificationCenter.default
        
        let localDatabaseDataSource = LocalDatabaseDataSource(
            modelContainer: modelContainerSpy.modelContainer,
            backgroundTasksManager: backgroundTasksManagerSpy,
            notificationCenter: notificationCenterDummy
        )
        
        sut = localDatabaseDataSource
        
        let mirrored = Mirror(reflecting: localDatabaseDataSource)
        for child in mirrored.children {
            guard let modelContext = child.value as? ModelContext else { continue }
            
            modelContextSpy = modelContext
            break
        }
        
        XCTAssertNotNil(modelContextSpy)
    }
    
    override func setUp() {
        super.setUp()
        
        DependenciesContainerManager.container = appDependencies
    }
    
    override func tearDown() {
        super.tearDown()
        
        modelContainerSpy.modelContainer.deleteAllData()
    }
    
    // MARK: Insert
    
    func testInsertModel() async {
        // Given
        let model = LocalDatabaseModelDummy(identifier: 123)
        
        let expectation = XCTNSNotificationExpectation(
            name: .localDatabaseDidChange,
            object: sut,
            notificationCenter: notificationCenterDummy
        )
        
        // When
        await sut.insert(model)
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(modelContextSpy?.insertedModelsArray.map { $0.persistentModelID }, [model.persistentModelID])
        
        let insertedModels: [LocalDatabaseModelDummy] = await sut.getInsertedModels()
        
        XCTAssertEqual(insertedModels, [model])
    }
    
    // MARK: Delete
    
    func testDeleteModelWhenModelHadBeenInsertedAndThenContentWasSaved() async throws {
        // Given
        let model = LocalDatabaseModelDummy(identifier: 123)
        
        await sut.insert(model)
        
        try await sut.save()
        
        let expectation = XCTNSNotificationExpectation(
            name: .localDatabaseDidChange,
            object: sut,
            notificationCenter: notificationCenterDummy
        )
        
        // When
        await sut.delete(model)
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        let deletedModels: [LocalDatabaseModelDummy] = await sut.getDeletedModels()
        let insertedModels: [LocalDatabaseModelDummy] = await sut.getInsertedModels()
        
        XCTAssertEqual(deletedModels, [model])
        XCTAssertTrue(insertedModels.isEmpty)
        XCTAssertTrue(model.isDeleted)
        
        XCTAssertEqual(modelContextSpy?.deletedModelsArray.map { $0.persistentModelID }, [model.persistentModelID])
        XCTAssertEqual(modelContextSpy?.insertedModelsArray.isEmpty, true)
    }
    
    func testDeleteModelWhenModelHadBeenInsertedAndThenContentWasNotSaved() async throws {
        // Given
        let model = LocalDatabaseModelDummy(identifier: 123)
        
        await sut.insert(model)
        
        let expectation = XCTNSNotificationExpectation(
            name: .localDatabaseDidChange,
            object: sut,
            notificationCenter: notificationCenterDummy
        )
        
        // When
        await sut.delete(model)
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        let deletedModels: [LocalDatabaseModelDummy] = await sut.getDeletedModels()
        let insertedModels: [LocalDatabaseModelDummy] = await sut.getInsertedModels()
        
//        XCTAssertTrue(deletedModels.isEmpty)
//        XCTAssertTrue(insertedModels.isEmpty)
//        
//        XCTAssertEqual(modelContextSpy?.deletedModelsArray.isEmpty, true)
//        XCTAssertEqual(modelContextSpy?.insertedModelsArray.isEmpty, true)
    }
    
    func testDeleteModelWhenModelHasBeenNotInserted() async {
        // Given
        let model = LocalDatabaseModelDummy(identifier: 123)
        
        // When
        await sut.delete(model)
        
        // Then
        XCTAssertEqual(modelContextSpy?.deletedModelsArray.isEmpty, true)
        
        // When
        let deletedModels: [LocalDatabaseModelDummy] = await sut.getDeletedModels()
        
        // Then
        XCTAssertTrue(deletedModels.isEmpty)
    }
    
    // MARK: Fetch
    
    func testFetch() async throws {
        // Given
        let model1 = LocalDatabaseModelDummy(identifier: 1)
        let model2 = LocalDatabaseModelDummy(identifier: 111)
        let model3 = LocalDatabaseModelDummy(identifier: 222)
        let model4 = LocalDatabaseModelDummy(identifier: 333)
        
        for model in [model1, model2, model3, model4] {
            await sut.insert(model)
        }
        
        let predicate = #Predicate<LocalDatabaseModelDummy> { model in
            model.identifier > 200
        }
        
        let sortDescriptor = SortDescriptor(\LocalDatabaseModelDummy.identifier, order: .reverse)
        
        // When
        let fetchedModels = try await sut.fetch(
            object: LocalDatabaseModelDummy.self,
            predicate: predicate,
            sorts: [sortDescriptor],
            fetchLimit: 2
        )
        
        // Then
        XCTAssertEqual(fetchedModels, [model4, model3])
    }
    
    // MARK: Save
    
    func testSave() async throws {
        // Given
        let model = LocalDatabaseModelDummy(identifier: 123)
        
        await sut.insert(model)
        
        let expectation = XCTNSNotificationExpectation(
            name: .localDatabaseDidSave,
            object: sut,
            notificationCenter: notificationCenterDummy
        )
        
        // When
        try await sut.save()
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertFalse(model.hasChanges)
    }
    
    //    FIXME
    //    SwiftData/BackingData.swift:630: Fatal error: This method expects to be able to copy the value out of the managed object in the default backing data.
    
    func testSaveWhenSceneWillDeactivateNotificationDidReceive() async throws {
        try XCTSkipIf(true)
        
        // Given
        let model = LocalDatabaseModelDummy(identifier: 123)
        
        await sut.insert(model)
        
        await XCTWaiter().fulfillment(of: [.init()], timeout: 0.2)
        
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2
        
        backgroundTasksManagerSpy.expectation = expectation
        
        // When
        await MainActor.run {
            notificationCenterDummy.post(name: UIScene.willDeactivateNotification, object: nil)
        }
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertFalse(model.hasChanges)
        XCTAssertEqual(modelContextSpy?.hasChanges, false)
        XCTAssertEqual(modelContextSpy?.insertedModelsArray.isEmpty, true)
    }
}
