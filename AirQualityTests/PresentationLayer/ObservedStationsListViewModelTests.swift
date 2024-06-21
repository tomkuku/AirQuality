//
//  ObservedStationsListViewModelTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 21/06/2024.
//

import XCTest
import Combine

@testable import AirQuality

final class ObservedStationsListViewModelTests: BaseTestCase, @unchecked Sendable {
    
    private var sut: ObservedStationsListViewModel!
    
    private var getObservedStationsUseCaseSpy: GetObservedStationsUseCaseSpy!
    private var deleteObservedStationsUseCaseSpy: DeleteObservedStationUseCaseSpy!
    
    private var station1: Station!
    private var station2: Station!
    private var station3: Station!
    
    override func setUp() {
        super.setUp()
        
        getObservedStationsUseCaseSpy = GetObservedStationsUseCaseSpy()
        deleteObservedStationsUseCaseSpy = DeleteObservedStationUseCaseSpy()
        
        dependenciesContainerDummy[\.getObservedStationsUseCase] = getObservedStationsUseCaseSpy
        dependenciesContainerDummy[\.deleteObservedStationUseCase] = deleteObservedStationsUseCaseSpy
        
        station1 = Station.dummy(id: 1, cityName: "Cracow", province: "Malopolska", street: "Bujaka")
        station2 = Station.dummy(id: 2, cityName: "Plock", province: "Mazowieckie", street: "Reja")
        station3 = Station.dummy(id: 3, cityName: "Cracow", province: "Malopolska", street: "Krasinskiego")
    }
    
    @MainActor
    func testStationsWhenAFewStationsAreobserved() {
        // Given
        getObservedStationsUseCaseSpy.createNewStreamInitialValue = [station1, station2]
        
        var stations: [Station] = []
        
        // When
        sut = ObservedStationsListViewModel()
        
        sut.$stations
            .dropFirst()
            .sink {
                stations = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(stations, [station1, station2])
        XCTAssertEqual(getObservedStationsUseCaseSpy.events, [.createNewStream])
    }
    
    @MainActor
    func testStationsWhenNoObservedStations() {
        // Given
        getObservedStationsUseCaseSpy.expectation = expectation
        
        // When
        sut = ObservedStationsListViewModel()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertTrue(sut.stations.isEmpty)
        XCTAssertEqual(getObservedStationsUseCaseSpy.events, [.createNewStream])
    }
    
    @MainActor
    func testStationsWhenObservedStationsChanged() {
        // Given
        getObservedStationsUseCaseSpy.createNewStreamInitialValue = [station1, station2]
        
        var stations: [Station] = []
        
        sut = ObservedStationsListViewModel()
        
        sut.$stations
            .dropFirst()
            .sink {
                stations = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        /// Wait for create new stream.
        wait(for: [expectation], timeout: 2.0)
        
        expectation = XCTestExpectation()
        
        // When
        getObservedStationsUseCaseSpy.stationsStremSubject.send([station1, station2, station3])
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(stations.count, 3)
        XCTAssertEqual(getObservedStationsUseCaseSpy.events, [.createNewStream])
    }
    
    @MainActor
    func testDeleteStation() {
        // Given
        sut = ObservedStationsListViewModel()
        
        var toast: Toast?
        
        sut.toastSubject
            .sink {
                toast = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.deletedObservedStation(station1)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(deleteObservedStationsUseCaseSpy.events, [.delete(station1)])
        XCTAssertNotNil(toast)
    }
    
    @MainActor
    func testDeleteStationWhenFailure() {
        // Given
        sut = ObservedStationsListViewModel()
        
        var alert: AlertModel?
        
        sut.alertSubject
            .sink {
                alert = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        deleteObservedStationsUseCaseSpy.deleteStationThrowError = ErrorDummy()
        
        // When
        sut.deletedObservedStation(station1)
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(deleteObservedStationsUseCaseSpy.events, [.delete(station1)])
        XCTAssertEqual(alert, .somethigWentWrong())
    }
}
