//
//  ToastsViewModelTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 20/09/2024.
//

import XCTest
import Combine

@testable import AirQuality

final class ToastsViewModelTests: BaseTestCase, @unchecked Sendable {

    private var sut: ToastsViewModel!
    
    private var toastSubject: PassthroughSubject<ToastModel, Never>!
    
    override func setUp() async throws {
        try await super.setUp()
        
        await MainActor.run {
            self.toastSubject = PassthroughSubject<ToastModel, Never>()
            self.sut = ToastsViewModel(self.toastSubject.eraseToAnyPublisher())
        }
    }
    
    @MainActor
    func testWhenOneToastWasPublished() {
        // Given
        let toast = ToastModel(body: "test")
        
        sut.$toasts
            .dropFirst()
            .sink { _ in
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        toastSubject.send(toast)

        // Then
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.toasts, [toast])
        
        // Given
        expectation = XCTestExpectation(description: "com.presentationAnimationDidComplete")
        
        sut.operationQueue.addOperation {
            self.expectation.fulfill()
        }
        
        // When
        sut.presentationAnimationDidComplete()
        
        // Then
        wait(for: [expectation])
    }
    
    @MainActor
    func testRemoveToast() {
        // Given
        let toast = ToastModel(body: "test")
        
        sut.$toasts
            .dropFirst()
            .sink { _ in
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        toastSubject.send(toast)

        // Then
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.toasts, [toast])
        
        // Given
        expectation = XCTestExpectation(description: "com.removeToast")
        
        // When
        sut.removeToast(toast)
        
        // Then
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.toasts.isEmpty)
    }
}
