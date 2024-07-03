//
//  AllStationStationViewModelTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 03/07/2024.
//

import XCTest

@testable import AirQuality

final class AllStationStationViewModelTests: BaseTestCase, @unchecked Sendable {
    
    private typealias AnnotationModel = AddObservedStationMapModel.StationAnnotation
    
    private var sut: AllStationStationViewModel!
    
    private var addObservedStationUseCaseSpy: AddObservedStationUseCaseSpy!
    private var deleteObservedStationUseCaseSpy: DeleteObservedStationUseCaseSpy!
    private var station: Station!
    
    override func setUp() async throws {
        try await super.setUp()
        
        addObservedStationUseCaseSpy = AddObservedStationUseCaseSpy()
        deleteObservedStationUseCaseSpy = DeleteObservedStationUseCaseSpy()
        
        dependenciesContainerDummy[\.addObservedStationUseCase] = addObservedStationUseCaseSpy
        dependenciesContainerDummy[\.deleteObservedStationUseCase] = deleteObservedStationUseCaseSpy
        
        station = .dummy()
        
        await MainActor.run {
            sut = AllStationStationViewModel(station: station)
        }
    }
    
    // MARK: addObservedStation
    
    @MainActor
    func testAddObservedStation() {
        // Given
        expectation.expectedFulfillmentCount = 2
        
        var toast: Toast?
        
        sut.toastSubject
            .sink {
                toast = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        addObservedStationUseCaseSpy.expectation = expectation
        deleteObservedStationUseCaseSpy.expectation = expectation
        
        // When
        sut.addObservedStation(station)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(addObservedStationUseCaseSpy.events, [.add(station)])
        XCTAssertTrue(deleteObservedStationUseCaseSpy.events.isEmpty)
        XCTAssertNotNil(toast)
    }
    
    @MainActor
    func testAddObservedStationWhenFailure() {
        // Given
        var alert: AlertModel?
        
        sut.alertSubject
            .sink {
                alert = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        addObservedStationUseCaseSpy.addStationThrowError = ErrorDummy()
        
        // When
        sut.addObservedStation(station)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(addObservedStationUseCaseSpy.events, [.add(station)])
        XCTAssertTrue(deleteObservedStationUseCaseSpy.events.isEmpty)
        XCTAssertEqual(alert, .somethigWentWrong())
    }
    
    // MARK: deletedObservedStation
    
    @MainActor
    func testDeletedObservedStation() {
        // Given
        expectation.expectedFulfillmentCount = 2
        
        var toast: Toast?
        
        sut.toastSubject
            .sink {
                toast = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        addObservedStationUseCaseSpy.expectation = expectation
        deleteObservedStationUseCaseSpy.expectation = expectation
        
        // When
        sut.deletedObservedStation(station)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertTrue(addObservedStationUseCaseSpy.events.isEmpty)
        XCTAssertEqual(deleteObservedStationUseCaseSpy.events, [.delete(station)])
        XCTAssertNotNil(toast)
    }
    
    @MainActor
    func testDeletedObservedStationWhenFailure() {
        // Given
        var alert: AlertModel?
        
        sut.alertSubject
            .sink {
                alert = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        deleteObservedStationUseCaseSpy.deleteStationThrowError = ErrorDummy()
        
        // When
        sut.deletedObservedStation(station)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertTrue(addObservedStationUseCaseSpy.events.isEmpty)
        XCTAssertEqual(deleteObservedStationUseCaseSpy.events, [.delete(station)])
        XCTAssertEqual(alert, .somethigWentWrong())
    }
}
