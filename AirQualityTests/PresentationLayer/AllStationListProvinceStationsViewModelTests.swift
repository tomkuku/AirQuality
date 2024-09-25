//
//  AllStationListProvinceStationsViewModelTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 25/09/2024.
//

import XCTest

@testable import AirQuality

final class AddStationToObservedListViewModelTests: BaseTestCase, @unchecked Sendable {
    
    private var sut: AllStationListProvinceStationsViewModel!
    
    private var getObservedStationsUseCaseSpy: GetObservedStationsUseCaseSpy!
    
    private var station1: Station!
    private var station2: Station!
    private var station3: Station!
    
    override func setUp() async throws {
        try await super.setUp()
        
        getObservedStationsUseCaseSpy = GetObservedStationsUseCaseSpy()
        
        dependenciesContainerDummy[\.getObservedStationsUseCase] = getObservedStationsUseCaseSpy
        
        station1 = Station.dummy(id: 1, cityName: "Cracow", province: "Malopolska", street: "Bujaka")
        station2 = Station.dummy(id: 2, cityName: "Plock", province: "Malopolska", street: "Reja")
        station3 = Station.dummy(id: 3, cityName: "Cracow", province: "Malopolska", street: "Krasinskiego")
        
        let stations: [Station] = [station1, station2, station3]
        
        await MainActor.run {
            sut = AllStationListProvinceStationsViewModel(allStationsInProvicne: stations)
        }
    }
    
    // MARK: fetchStations
    
    @MainActor
    func testFetchStations() {
        // Given
        getObservedStationsUseCaseSpy.fetchStationsResult = .success([station2])
        
        var sections: [(station: Station, isObserved: Bool)]?
        
        sut.$stations
            .dropFirst()
            .sink {
                sections = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.fetchStations()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(sections?.map { $0.station }, [station1, station2, station3])
        XCTAssertEqual(sections?.map { $0.isObserved }, [false, true, false])
        XCTAssertEqual(getObservedStationsUseCaseSpy.events, [.createNewStream, .fetchedStations])
    }
    
    @MainActor
    func testFetchStationsWhenNoObservedStations() {
        // Given
        getObservedStationsUseCaseSpy.fetchStationsResult = .success([])
        
        var sections: [(station: Station, isObserved: Bool)]?
        
        sut.$stations
            .dropFirst()
            .sink {
                sections = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.fetchStations()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(sections?.map { $0.station }, [station1, station2, station3])
        XCTAssertEqual(sections?.map { $0.isObserved }, [false, false, false])
        XCTAssertEqual(getObservedStationsUseCaseSpy.events, [.createNewStream, .fetchedStations])
    }
    
    @MainActor
    func testFetchStationsWhenObservedStationsDidChange() {
        // Given
        getObservedStationsUseCaseSpy.fetchStationsResult = .success([station2, station3])
        
        var sections: [(station: Station, isObserved: Bool)]?
        
        sut.$stations
            .dropFirst()
            .sink {
                sections = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.fetchStations()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(sections?.map { $0.station }, [station1, station2, station3])
        XCTAssertEqual(sections?.map { $0.isObserved }, [false, true, true])
        XCTAssertEqual(getObservedStationsUseCaseSpy.events, [.createNewStream, .fetchedStations])
        
        // Given
        expectation = XCTestExpectation()
        
        // When
        getObservedStationsUseCaseSpy.stationsStremSubject.send([station1])
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(sections?.map { $0.station }, [station1, station2, station3])
        XCTAssertEqual(sections?.map { $0.isObserved }, [true, false, false])
        XCTAssertEqual(getObservedStationsUseCaseSpy.events, [.createNewStream, .fetchedStations])
    }
    
    @MainActor
    func testFetchStationsWhenFetchingObservedStationsFailed() {
        // Given
        getObservedStationsUseCaseSpy.fetchStationsResult = .failure(ErrorDummy())
        
        var alert: AlertModel?
        
        sut.alertSubject
            .sink {
                alert = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.$stations
            .dropFirst()
            .sink { _ in
                XCTFail("Stations publisher should not have pubslihed!")
            }
            .store(in: &cancellables)
        
        // When
        sut.fetchStations()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(getObservedStationsUseCaseSpy.events, [.createNewStream, .fetchedStations])
        XCTAssertEqual(alert, .somethigWentWrong())
    }
}
