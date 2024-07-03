//
//  AddStationToObservedListViewModelTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 16/06/2024.
//

import XCTest

@testable import AirQuality

final class AddStationToObservedListViewModelTests: BaseTestCase, @unchecked Sendable {
    
    private var sut: AddStationToObservedListViewModel!
    
    private var getObservedStationsUseCaseSpy: GetObservedStationsUseCaseSpy!
    private var fetchAllStationsUseCaseSpy: FetchAllStationsUseCaseSpy!
    
    private var station1: Station!
    private var station2: Station!
    private var station3: Station!
    private var station4: Station!
    private var station5: Station!
    private var station6: Station!
    
    override func setUp() async throws {
        try await super.setUp()
        
        getObservedStationsUseCaseSpy = GetObservedStationsUseCaseSpy()
        fetchAllStationsUseCaseSpy = FetchAllStationsUseCaseSpy()
        
        dependenciesContainerDummy[\.getObservedStationsUseCase] = getObservedStationsUseCaseSpy
        dependenciesContainerDummy[\.fetchAllStationsUseCase] = fetchAllStationsUseCaseSpy
        
        station1 = Station.dummy(id: 1, cityName: "Cracow", province: "Malopolska", street: "Bujaka")
        station2 = Station.dummy(id: 2, cityName: "Plock", province: "Mazowieckie", street: "Reja")
        station3 = Station.dummy(id: 3, cityName: "Cracow", province: "Malopolska", street: "Krasinskiego")
        station4 = Station.dummy(id: 4, cityName: "Warszawa", province: "Mazowieckie", street: "Sienkiewicza")
        station5 = Station.dummy(id: 5, cityName: "Zakopane", province: "Malopolska", street: "Sienkiewicza")
        station6 = Station.dummy(id: 6, cityName: "Warszawa", province: "Mazowieckie", street: "Wokalna")
        
        await MainActor.run {
            sut = AddStationToObservedListViewModel()
        }
    }
    
    // MARK: fetchStations
    
    @MainActor
    func testFetchStations() {
        // Given
        fetchAllStationsUseCaseSpy.fetchStationsResult = .success([
            station1, station2, station3, station4, station5, station6
        ])
        
        getObservedStationsUseCaseSpy.fetchStationsResult = .success([
            station2, station5
        ])
        
        var sections: [AddStationToObservedListModel.Section]?
        
        expectation.expectedFulfillmentCount = 3
        
        sut.objectWillChange
            .sink { _ in
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.$sections
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
        
        XCTAssertEqual(sections, [
            .init(name: "Malopolska", rows: [
                .init(station: station1, isStationObserved: false),
                .init(station: station3, isStationObserved: false),
                .init(station: station5, isStationObserved: true)
            ]),
            .init(name: "Mazowieckie", rows: [
                .init(station: station2, isStationObserved: true),
                .init(station: station4, isStationObserved: false),
                .init(station: station6, isStationObserved: false)
            ])
        ])
        XCTAssertEqual(getObservedStationsUseCaseSpy.events, [.createNewStream, .fetchedStations])
        XCTAssertEqual(fetchAllStationsUseCaseSpy.events, [.fetch])
    }
    
    @MainActor
    func testFetchStationsWhenNoObservedStations() {
        // Given
        fetchAllStationsUseCaseSpy.fetchStationsResult = .success([
            station1, station2, station3, station4, station5, station6
        ])
        
        getObservedStationsUseCaseSpy.fetchStationsResult = .success([])
        
        var sections: [AddStationToObservedListModel.Section]?
        
        expectation.expectedFulfillmentCount = 3
        
        sut.objectWillChange
            .sink { _ in
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.$sections
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
        
        XCTAssertEqual(sections, [
            .init(name: "Malopolska", rows: [
                .init(station: station1, isStationObserved: false),
                .init(station: station3, isStationObserved: false),
                .init(station: station5, isStationObserved: false)
            ]),
            .init(name: "Mazowieckie", rows: [
                .init(station: station2, isStationObserved: false),
                .init(station: station4, isStationObserved: false),
                .init(station: station6, isStationObserved: false)
            ])
        ])
        XCTAssertEqual(getObservedStationsUseCaseSpy.events, [.createNewStream, .fetchedStations])
        XCTAssertEqual(fetchAllStationsUseCaseSpy.events, [.fetch])
    }
    
    @MainActor
    func testFetchStationsWhenObservedStationsDidChange() {
        // Given
        fetchAllStationsUseCaseSpy.fetchStationsResult = .success([
            station1, station2, station3, station4, station5, station6
        ])
        
        getObservedStationsUseCaseSpy.fetchStationsResult = .success([
            station2, station5
        ])
        
        var sections: [AddStationToObservedListModel.Section]?
        
        expectation.expectedFulfillmentCount = 3
        
        sut.objectWillChange
            .sink { _ in
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.$sections
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
        
        XCTAssertEqual(sections, [
            .init(name: "Malopolska", rows: [
                .init(station: station1, isStationObserved: false),
                .init(station: station3, isStationObserved: false),
                .init(station: station5, isStationObserved: true)
            ]),
            .init(name: "Mazowieckie", rows: [
                .init(station: station2, isStationObserved: true),
                .init(station: station4, isStationObserved: false),
                .init(station: station6, isStationObserved: false)
            ])
        ])
        XCTAssertEqual(getObservedStationsUseCaseSpy.events, [.createNewStream, .fetchedStations])
        XCTAssertEqual(fetchAllStationsUseCaseSpy.events, [.fetch])
        
        // Given
        expectation = XCTestExpectation()
        
        // When
        getObservedStationsUseCaseSpy.stationsStremSubject.send([station1, station5, station2])
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(sections, [
            .init(name: "Malopolska", rows: [
                .init(station: station1, isStationObserved: true),
                .init(station: station3, isStationObserved: false),
                .init(station: station5, isStationObserved: true)
            ]),
            .init(name: "Mazowieckie", rows: [
                .init(station: station2, isStationObserved: true),
                .init(station: station4, isStationObserved: false),
                .init(station: station6, isStationObserved: false)
            ])
        ])
        XCTAssertEqual(getObservedStationsUseCaseSpy.events, [.createNewStream, .fetchedStations])
    }
    
    @MainActor
    func testFetchStationsWhenFetchingStationsFailed() {
        // Given
        fetchAllStationsUseCaseSpy.fetchStationsResult = .failure(ErrorDummy())
        getObservedStationsUseCaseSpy.fetchStationsResult = .success([])
        
        var alert: AlertModel?
        
        sut.alertSubject
            .sink {
                alert = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.$sections
            .dropFirst()
            .sink { _ in
                XCTFail("Sections publisher should not have pubslihed!")
            }
            .store(in: &cancellables)
        
        // When
        sut.fetchStations()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(getObservedStationsUseCaseSpy.events, [.createNewStream])
        XCTAssertEqual(fetchAllStationsUseCaseSpy.events, [.fetch])
        XCTAssertEqual(alert, .somethigWentWrong())
    }
    
    @MainActor
    func testFetchStationsWhenFetchingObservedStationsFailed() {
        // Given
        fetchAllStationsUseCaseSpy.fetchStationsResult = .success([])
        getObservedStationsUseCaseSpy.fetchStationsResult = .failure(ErrorDummy())
        
        var alert: AlertModel?
        
        sut.alertSubject
            .sink {
                alert = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.$sections
            .dropFirst()
            .sink { _ in
                XCTFail("Sections publisher should not have pubslihed!")
            }
            .store(in: &cancellables)
        
        // When
        sut.fetchStations()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(getObservedStationsUseCaseSpy.events, [.createNewStream, .fetchedStations])
        XCTAssertEqual(fetchAllStationsUseCaseSpy.events, [.fetch])
        XCTAssertEqual(alert, .somethigWentWrong())
    }
    
    // MARK: testSearchedTextDidChange
    
    @MainActor
    func testSearchedTextDidChange() {
        // Given
        fetchAllStationsUseCaseSpy.fetchStationsResult = .success([
            station1, station2, station3, station4, station5, station6
        ])
        
        getObservedStationsUseCaseSpy.fetchStationsResult = .success([
            station2, station3
        ])
        
        var sections: [AddStationToObservedListModel.Section]?
        
        sut.$sections
            .dropFirst()
            .sink {
                sections = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fetchStations()
        
        wait(for: [expectation], timeout: 2.0)
        
        // Given
        expectation = XCTestExpectation()
        
        // When
        sut.searchedTextDidChange("Cracow")
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(sections, [
            .init(name: "Malopolska", rows: [
                .init(station: station1, isStationObserved: false),
                .init(station: station3, isStationObserved: true)
            ])
        ])
        XCTAssertEqual(getObservedStationsUseCaseSpy.events, [.createNewStream, .fetchedStations, .fetchedStations])
    }
    
    @MainActor
    func testSearchedTextDidChangeWhenAnyStationDoNotMatchToIt() {
        // Given
        fetchAllStationsUseCaseSpy.fetchStationsResult = .success([
            station1, station2, station3, station4, station5, station6
        ])
        
        getObservedStationsUseCaseSpy.fetchStationsResult = .success([
            station2, station3
        ])
        
        var sections: [AddStationToObservedListModel.Section]?
        
        sut.$sections
            .dropFirst()
            .sink {
                sections = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fetchStations()
        
        wait(for: [expectation], timeout: 2.0)
        
        // Given
        expectation = XCTestExpectation()
        
        // When
        sut.searchedTextDidChange("Szczecin")
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(sections?.isEmpty, true)
        XCTAssertEqual(getObservedStationsUseCaseSpy.events, [.createNewStream, .fetchedStations, .fetchedStations])
    }
}

extension AddStationToObservedListModel.Section: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name && lhs.rows == rhs.rows
    }
}

extension AddStationToObservedListModel.Row: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.station == rhs.station && lhs.isStationObserved == rhs.isStationObserved
    }
}
