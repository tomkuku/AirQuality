//
//  AllStationsListProvincesViewModelTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 16/06/2024.
//

import XCTest

@testable import AirQuality

final class AllStationsListProvincesViewModelTests: BaseTestCase, @unchecked Sendable {
    
    private var sut: AllStationsListProvincesViewModel!
    
    private var fetchAllStationsUseCaseSpy: FetchAllStationsUseCaseSpy!
    private var networkConnectionMonitorUseCaseSpy: NetworkConnectionMonitorUseCaseSpy!
    
    private var station1: Station!
    private var station2: Station!
    private var station3: Station!
    private var station4: Station!
    private var station5: Station!
    private var station6: Station!
    
    override func setUp() async throws {
        try await super.setUp()
        
        fetchAllStationsUseCaseSpy = FetchAllStationsUseCaseSpy()
        networkConnectionMonitorUseCaseSpy = NetworkConnectionMonitorUseCaseSpy()
        
        dependenciesContainerDummy[\.fetchAllStationsUseCase] = fetchAllStationsUseCaseSpy
        dependenciesContainerDummy[\.networkConnectionMonitorUseCase] = networkConnectionMonitorUseCaseSpy
        
        station1 = Station.dummy(id: 1, cityName: "Cracow", province: "Malopolska", street: "Bujaka")
        station2 = Station.dummy(id: 2, cityName: "Plock", province: "Mazowieckie", street: "Reja")
        station3 = Station.dummy(id: 3, cityName: "Cracow", province: "Malopolska", street: "Krasinskiego")
        station4 = Station.dummy(id: 4, cityName: "Warszawa", province: "Mazowieckie", street: "Sienkiewicza")
        station5 = Station.dummy(id: 5, cityName: "Zakopane", province: "Malopolska", street: "Sienkiewicza")
        station6 = Station.dummy(id: 6, cityName: "Warszawa", province: "Mazowieckie", street: "Wokalna")
        
        await MainActor.run {
            sut = AllStationsListProvincesViewModel()
        }
    }
    
    // MARK: fetchStations
    
    @MainActor
    func testFetchStations() {
        // Given
        networkConnectionMonitorUseCaseSpy.isConnectionSatisfiedReturnValue = true
        
        fetchAllStationsUseCaseSpy.fetchStationsResult = .success([
            station1, station2, station3, station4, station5, station6
        ])
        
        var provinces: [AllStationsListProvindesModel.Province]?
        
        sut.$provinces
            .dropFirst()
            .sink {
                provinces = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.fetchStations()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(provinces, [
            .init(name: "Malopolska", stations: [station1, station3, station5]),
            .init(name: "Mazowieckie", stations: [station2, station4, station6])
        ])
        XCTAssertEqual(fetchAllStationsUseCaseSpy.events, [.fetch])
    }
    
    @MainActor
    func testFetchStationsWhenFetchingStationsFailed() {
        // Given
        networkConnectionMonitorUseCaseSpy.isConnectionSatisfiedReturnValue = true
        
        fetchAllStationsUseCaseSpy.fetchStationsResult = .failure(ErrorDummy())
        
        var error: Error?
        
        sut.errorSubject
            .sink {
                error = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.$provinces
            .dropFirst()
            .sink { _ in
                XCTFail("Provinces publisher should not have published!")
            }
            .store(in: &cancellables)
        
        // When
        sut.fetchStations()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        guard error is ErrorDummy else {
            XCTFail("Error should be equal to ErrorDummy!")
            return
        }
        
        XCTAssertEqual(fetchAllStationsUseCaseSpy.events, [.fetch])
    }
    
    // MARK: SearchedText DidChange
    
    @MainActor
    func testSearchedTextDidChangeWhenStationCityNameIsSearched() {
        // Given
        networkConnectionMonitorUseCaseSpy.isConnectionSatisfiedReturnValue = true
        
        fetchAllStationsUseCaseSpy.fetchStationsResult = .success([
            station1, station2, station3, station4, station5, station6
        ])
        
        var provinces: [AllStationsListProvindesModel.Province]?
        
        sut.$provinces
            .dropFirst()
            .sink {
                provinces = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fetchStations()
        
        wait(for: [expectation], timeout: 2.0)
        
        // Given
        expectation = XCTestExpectation()
        
        // When
        sut.searchedText = "Cracow"
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(provinces, [
            .init(name: "Malopolska", stations: [station1, station3])
        ])
    }
    
    @MainActor
    func testSearchedTextDidChangeWhenStationStreetIsSearched() {
        // Given
        networkConnectionMonitorUseCaseSpy.isConnectionSatisfiedReturnValue = true
        
        fetchAllStationsUseCaseSpy.fetchStationsResult = .success([
            station1, station2, station3, station4, station5, station6
        ])
        
        var provinces: [AllStationsListProvindesModel.Province]?
        
        sut.$provinces
            .dropFirst()
            .sink {
                provinces = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fetchStations()
        
        wait(for: [expectation], timeout: 2.0)
        
        // Given
        expectation = XCTestExpectation()
        
        // When
        sut.searchedText = "Krasinskiego"
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(provinces, [
            .init(name: "Malopolska", stations: [station3])
        ])
    }
    
    @MainActor
    func testSearchedTextDidChangeWhenAnyStationDoesNotMatch() {
        // Given
        networkConnectionMonitorUseCaseSpy.isConnectionSatisfiedReturnValue = true
        
        fetchAllStationsUseCaseSpy.fetchStationsResult = .success([
            station1, station2, station3, station4, station5, station6
        ])
        
        var provinces: [AllStationsListProvindesModel.Province]?
        
        sut.$provinces
            .dropFirst()
            .sink {
                provinces = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fetchStations()
        
        wait(for: [expectation], timeout: 2.0)
        
        // Given
        expectation = XCTestExpectation()
        
        // When
        sut.searchedText = "New York"
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(provinces?.isEmpty, true)
    }
}

extension AllStationsListProvindesModel.Province: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name && lhs.stations == rhs.stations
    }
}
