//
//  AlertViewModelTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 17/05/2024.
//

import XCTest
import Combine
import Alamofire

@testable import AirQuality

final class AlertViewModelTests: BaseTestCase {

    private var sut: AlertViewModel!
    
    private var alertSubject: PassthroughSubject<AlertModel, Never>!
    
    override func setUp() {
        super.setUp()
        
        DependenciesContainerManager.container = appDependencies
        
        alertSubject = PassthroughSubject<AlertModel, Never>()
        
        sut = AlertViewModel(alertSubject)
    }
    
    @MainActor
    func testIsAnyAlertPresentedWhenAlertOneWasPublished() {
        // Given
        let alert = AlertModel(title: "Title", buttons: [.ok()])
        
        var isAnyAlertPresented: Bool?
        
        sut.$isAnyAlertPresented
            .dropFirst()
            .sink { value in
                isAnyAlertPresented = value
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        alertSubject.send(alert)

        // Then
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(isAnyAlertPresented, true)
        XCTAssertEqual(sut.alerts, [alert])
    }
    
    @MainActor
    func testWhenIsAnyAlertPresentedChangedToFalseAndNoAlertsLeftToPresent() {
        // Given
        let alert = AlertModel(title: "Title", buttons: [.ok()])
        
        var isAnyAlertPresented: Bool?
        
        sut.$isAnyAlertPresented
            .dropFirst()
            .sink { value in
                isAnyAlertPresented = value
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        alertSubject.send(alert)

        // Then
        wait(for: [expectation], timeout: 2)
        
        // Given
        expectation = XCTestExpectation()
        
        // When
        sut.isAnyAlertPresented = false
        
        // Then
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(isAnyAlertPresented, false)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.5)
        
        XCTAssertTrue(sut.alerts.isEmpty)
    }
    
    @MainActor
    func testWhenIsAnyAlertPresentedChangedToFalseAndOneAlertLeftToPresent() {
        // Given
        let alert1 = AlertModel(title: "Title 1", buttons: [.ok()])
        let alert2 = AlertModel(title: "Title 2", buttons: [.ok()])
        
        var isAnyAlertPresented: Bool?
        
        expectation.expectedFulfillmentCount = 2
        
        sut.$isAnyAlertPresented
            .dropFirst()
            .sink { value in
                isAnyAlertPresented = value
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        alertSubject.send(alert1)
        alertSubject.send(alert2)

        // Then
        wait(for: [expectation])
        
        // Given
        expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2
        
        // When
        sut.isAnyAlertPresented = false
        
        // Then
        wait(for: [expectation])
        
        XCTAssertEqual(isAnyAlertPresented, true)
        XCTAssertEqual(sut.alerts, [alert2])
    }
}
