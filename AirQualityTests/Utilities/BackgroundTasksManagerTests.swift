//
//  BackgroundTasksManagerTests.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 03/06/2024.
//

import XCTest
import struct UIKit.UIBackgroundTaskIdentifier

@testable import AirQuality

final class BackgroundTasksManagerTests: BaseTestCase, @unchecked Sendable {
    
    private var sut: BackgroundTasksManager!
    
    private var uiApplicationSpy: UIApplicationSpy!
    
    private var taskName: String!
    private var beginBackgroundTaskIdentifier: UIBackgroundTaskIdentifier!
    
    override func setUp() {
        super.setUp()
        
        DependenciesContainerManager.container = appDependencies
        
        taskName = "test.name"
        beginBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 1)
        
        uiApplicationSpy = UIApplicationSpy()
        
        sut = BackgroundTasksManager(uiApplication: uiApplicationSpy)
    }
    
    @MainActor
    func testBeginFiniteLengthTask() {
        // When
        sut.beginFiniteLengthTask(taskName, completion: nil)
        
        // Then
        XCTAssertEqual(uiApplicationSpy.events.value, [.beginBackgroundTask(taskName)])
    }
    
    @MainActor
    func testEndFiniteLengthTask() {
        // Given
        uiApplicationSpy.beginBackgroundTaskReturnValue.value = beginBackgroundTaskIdentifier
        
        sut.beginFiniteLengthTask(taskName, completion: nil)
        
        // When
        sut.endFiniteLengthTask(taskName)
        
        // Then
        XCTAssertEqual(uiApplicationSpy.events.value, [
            .beginBackgroundTask(taskName),
            .endBackgroundTask(beginBackgroundTaskIdentifier)
        ])
    }
    
    @MainActor
    func testEndFiniteLengthTaskWhenNoTaskWithPassedName() {
        // When
        sut.endFiniteLengthTask(name)
        
        // Then
        XCTAssertTrue(uiApplicationSpy.events.value.isEmpty)
    }
    
    @MainActor
    func testWhenOperatingSystemInterruptsTask() {
        // Given
        uiApplicationSpy.beginBackgroundTaskReturnValue.value = beginBackgroundTaskIdentifier
        
        sut.beginFiniteLengthTask(taskName) {
            self.expectation.fulfill()
        }
        
        // When
        uiApplicationSpy.beginBackgroundTaskExpirationHandler.value?()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(uiApplicationSpy.events.value, [
            .beginBackgroundTask(taskName),
            .endBackgroundTask(beginBackgroundTaskIdentifier)
        ])
    }
}
