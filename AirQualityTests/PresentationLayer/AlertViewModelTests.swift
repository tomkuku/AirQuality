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

final class AlertViewModelTests: BaseTestCase, @unchecked Sendable {

    private var sut: AlertViewModel!
    
    private var coordinatorDelegateMock: CoordinatorDelegateMock!
    
    private var alertSubject: PassthroughSubject<AlertModel, Never>!
    private var coordinatorExpectation: XCTestExpectation!
    
    override func setUp() async throws {
        try await super.setUp()
        
        DependenciesContainerManager.container = appDependencies
        
        await MainActor.run {
            let alertSubject = PassthroughSubject<AlertModel, Never>()
            let coordinatorExpectation = XCTestExpectation(description: "com.coordinator.expectation")
            
            self.coordinatorDelegateMock = CoordinatorDelegateMock()
            self.coordinatorDelegateMock.expectation = coordinatorExpectation
            
            self.sut = AlertViewModel(alertSubject.eraseToAnyPublisher())
            self.sut.delegate = self.coordinatorDelegateMock
            
            self.alertSubject = alertSubject
            self.coordinatorExpectation = coordinatorExpectation
        }
    }
    
    @MainActor
    func testWhenOneAlertWasPublished() {
        // Given
        let alert = AlertModel(title: "Title", buttons: [.ok()])
        
        sut.objectWillChange
            .sink { _ in
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        alertSubject.send(alert)

        // Then
        wait(for: [expectation, coordinatorExpectation], timeout: 2)
        
        XCTAssertEqual(coordinatorDelegateMock.events, [.receivedAlert])
        XCTAssertEqual(sut.alerts, [alert])
        XCTAssertTrue(sut.isAnyAlertPresented)
    }
    
    @MainActor
    func testWhenAlertWasDimissedAndNoAlertsLeftToPresent() {
        // Given
        let alertDismissExpectation = XCTestExpectation(description: "alert.dismiss.expectation")
        
        let alert = AlertModel(title: "Title", buttons: [.ok()], dismissAction: {
            alertDismissExpectation.fulfill()
        })
        
        sut.objectWillChange
            .sink { _ in
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        alertSubject.send(alert)

        // Then
        wait(for: [expectation], timeout: 2)
        
        // Given
        coordinatorExpectation = XCTestExpectation(description: "com.coordinator.expectation")
        coordinatorDelegateMock.expectation = coordinatorExpectation
        
        // When
        sut.isAnyAlertPresented = false
        
        // Then
        wait(for: [coordinatorExpectation, alertDismissExpectation], timeout: 2)
        
        XCTAssertEqual(coordinatorDelegateMock.events, [.receivedAlert, .haveNoAlertsInQueue])
        XCTAssertTrue(sut.alerts.isEmpty)
        XCTAssertFalse(sut.isAnyAlertPresented)
    }
    
    @MainActor
    func testWhenAlertWasDismissedAndOneAlertLeftToPresent() {
        // Given
        let alertDismissExpectation = XCTestExpectation(description: "alert.dismiss.expectation")
        
        let alert1 = AlertModel(title: "Title 1", buttons: [.ok()], dismissAction: {
            alertDismissExpectation.fulfill()
        })
        
        let alert2 = AlertModel(title: "Title 2", buttons: [.ok()], dismissAction: {
            XCTFail("Dismiss action should not be called!")
        })
        
        sut.objectWillChange
            .sink { _ in
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        alertSubject.send(alert1)
        alertSubject.send(alert2)

        // Then
        wait(for: [expectation, coordinatorExpectation], timeout: 2)
        
        // Given
        expectation = XCTestExpectation()
        
        // When
        sut.isAnyAlertPresented = false
        
        // Then
        wait(for: [expectation, alertDismissExpectation], timeout: 2)
        
        XCTAssertEqual(coordinatorDelegateMock.events, [.receivedAlert])
        XCTAssertEqual(sut.alerts, [alert2])
        XCTAssertTrue(sut.isAnyAlertPresented)
    }
    
    // MARK: CoordinatorDelegateMock
    
    private final class CoordinatorDelegateMock: AlertsCoordinatorViewModelDelegate {
        enum Event: Equatable {
            case haveNoAlertsInQueue
            case receivedAlert
        }
        
        var events: [Event] = []
        var expectation: XCTestExpectation?
        
        func alertsViewModelHaveNoAlertsInQueue() {
            events.append(.haveNoAlertsInQueue)
            expectation?.fulfill()
        }
        
        func alertsViewModelReceivedAlert() {
            events.append(.receivedAlert)
            expectation?.fulfill()
        }
    }
}
