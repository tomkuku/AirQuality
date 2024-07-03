//
//  AddObservedStationMapViewModel.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 18/06/2024.
//

import XCTest

@testable import AirQuality

final class AddObservedStationMapViewModelTests: BaseTestCase, @unchecked Sendable {
    
    private typealias AnnotationModel = AddObservedStationMapModel.StationAnnotation
    
    private var sut: AddObservedStationMapViewModel!
    
    private var getObservedStationsUseCaseSpy: GetObservedStationsUseCaseSpy!
    private var fetchAllStationsUseCaseSpy: FetchAllStationsUseCaseSpy!
    private var findTheNearestStationUseCaseSpy: FindTheNearestStationUseCaseSpy!
    
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
        findTheNearestStationUseCaseSpy = FindTheNearestStationUseCaseSpy()
        
        dependenciesContainerDummy[\.getObservedStationsUseCase] = getObservedStationsUseCaseSpy
        dependenciesContainerDummy[\.fetchAllStationsUseCase] = fetchAllStationsUseCaseSpy
        dependenciesContainerDummy[\.findTheNearestStationUseCase] = findTheNearestStationUseCaseSpy
        
        station1 = Station.dummy(id: 1, cityName: "Cracow", province: "Malopolska", street: "Bujaka")
        station2 = Station.dummy(id: 2, cityName: "Plock", province: "Mazowieckie", street: "Reja")
        station3 = Station.dummy(id: 3, cityName: "Cracow", province: "Malopolska", street: "Krasinskiego")
        station4 = Station.dummy(id: 4, cityName: "Warszawa", province: "Mazowieckie", street: "Sienkiewicza")
        station5 = Station.dummy(id: 5, cityName: "Zakopane", province: "Malopolska", street: "Sienkiewicza")
        station6 = Station.dummy(id: 6, cityName: "Warszawa", province: "Mazowieckie", street: "Wokalna")
        
        await MainActor.run {
            sut = AddObservedStationMapViewModel()
        }
    }
    
    // MARK: fetchStations
    
    @MainActor
    func testFetchStations() {
        // Given
        var annotations: [AddObservedStationMapModel.StationAnnotation]?
        
        fetchAllStationsUseCaseSpy.fetchStationsResult = .success([
            station1, station2, station3, station4, station5, station6
        ])
        
        getObservedStationsUseCaseSpy.fetchStationsResult = .success([
            station2, station5
        ])
        
        expectation.expectedFulfillmentCount = 2
        
        sut.objectWillChange
            .sink { _ in
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.$annotations
            .dropFirst()
            .sink {
                annotations = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.fetchStations()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(annotations, [
            AnnotationModel(station: station1, isStationObserved: false),
            AnnotationModel(station: station2, isStationObserved: true),
            AnnotationModel(station: station3, isStationObserved: false),
            AnnotationModel(station: station4, isStationObserved: false),
            AnnotationModel(station: station5, isStationObserved: true),
            AnnotationModel(station: station6, isStationObserved: false)
        ])
        XCTAssertEqual(getObservedStationsUseCaseSpy.events, [.createNewStream, .fetchedStations])
        XCTAssertEqual(fetchAllStationsUseCaseSpy.events, [.fetch])
        XCTAssertFalse(sut.isLoading)
    }
    
    @MainActor
    func testFetchStationsWhenNoObservedStations() {
        // Given
        var annotations: [AddObservedStationMapModel.StationAnnotation]?
        
        fetchAllStationsUseCaseSpy.fetchStationsResult = .success([
            station1, station2, station3, station4, station5, station6
        ])
        
        getObservedStationsUseCaseSpy.fetchStationsResult = .success([])
        
        expectation.expectedFulfillmentCount = 2
        
        sut.objectWillChange
            .sink { _ in
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.$annotations
            .dropFirst()
            .sink {
                annotations = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.fetchStations()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(annotations, [
            AnnotationModel(station: station1, isStationObserved: false),
            AnnotationModel(station: station2, isStationObserved: false),
            AnnotationModel(station: station3, isStationObserved: false),
            AnnotationModel(station: station4, isStationObserved: false),
            AnnotationModel(station: station5, isStationObserved: false),
            AnnotationModel(station: station6, isStationObserved: false)
        ])
        XCTAssertEqual(getObservedStationsUseCaseSpy.events, [.createNewStream, .fetchedStations])
        XCTAssertEqual(fetchAllStationsUseCaseSpy.events, [.fetch])
        XCTAssertFalse(sut.isLoading)
    }
    
    @MainActor
    func testFetchStationsWhenObservedStationsDidChange() {
        // Given
        var annotations: [AddObservedStationMapModel.StationAnnotation]?
        
        fetchAllStationsUseCaseSpy.fetchStationsResult = .success([
            station1, station2, station3, station4, station5, station6
        ])
        
        getObservedStationsUseCaseSpy.fetchStationsResult = .success([
            station2, station5
        ])
        
        sut.$annotations
            .dropFirst()
            .sink {
                annotations = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.fetchStations()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(annotations, [
            AnnotationModel(station: station1, isStationObserved: false),
            AnnotationModel(station: station2, isStationObserved: true),
            AnnotationModel(station: station3, isStationObserved: false),
            AnnotationModel(station: station4, isStationObserved: false),
            AnnotationModel(station: station5, isStationObserved: true),
            AnnotationModel(station: station6, isStationObserved: false)
        ])
        XCTAssertEqual(getObservedStationsUseCaseSpy.events, [.createNewStream, .fetchedStations])
        XCTAssertEqual(fetchAllStationsUseCaseSpy.events, [.fetch])
        
        // Given
        expectation = XCTestExpectation()
        
        // When
        getObservedStationsUseCaseSpy.stationsStremSubject.send([station1, station5, station2])
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(annotations, [
            AnnotationModel(station: station1, isStationObserved: true),
            AnnotationModel(station: station2, isStationObserved: true),
            AnnotationModel(station: station3, isStationObserved: false),
            AnnotationModel(station: station4, isStationObserved: false),
            AnnotationModel(station: station5, isStationObserved: true),
            AnnotationModel(station: station6, isStationObserved: false)
        ])
        XCTAssertEqual(getObservedStationsUseCaseSpy.events, [.createNewStream, .fetchedStations])
        XCTAssertEqual(fetchAllStationsUseCaseSpy.events, [.fetch])
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
        
        sut.$annotations
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
        
        sut.$annotations
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
    
    // MARK: findTheNearestStation
    
    @MainActor
    func testFindTheNearestStation() {
        // Given
        let station = Station.dummy()
        
        findTheNearestStationUseCaseSpy.findStationsResult = .success((station, 12))
        
        var foundTheNearestStation: Station?
        
        sut.theNearestStationPublisher
            .sink {
                foundTheNearestStation = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.findTheNearestStation()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(foundTheNearestStation, station)
    }
    
    @MainActor
    func testFindTheNearestStationWhenFailure() {
        // Given
        findTheNearestStationUseCaseSpy.findStationsResult = .failure(ErrorDummy())
        
        var alert: AlertModel?
        
        sut.alertSubject
            .sink {
                alert = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.theNearestStationPublisher
            .sink { _ in
                XCTFail("theNearestStationPublisher should not publish any value!")
            }
            .store(in: &cancellables)
        
        // When
        sut.findTheNearestStation()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertNotNil(alert)
    }
}

extension AddObservedStationMapModel.StationAnnotation: Equatable, Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.station == rhs.station && lhs.isStationObserved == rhs.isStationObserved
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(station.id)
    }
}
