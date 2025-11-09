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
    
    private var networkConnectionMonitorUseCaseSpy: NetworkConnectionMonitorUseCaseSpy!
    private var getObservedStationsUseCaseSpy: GetObservedStationsUseCaseSpy!
    private var fetchAllStationsUseCaseSpy: FetchAllStationsUseCaseSpy!
    private var findTheNearestStationUseCaseSpy: FindTheNearestStationUseCaseSpy!
    private var getUserLocationUseCaseMock: GetUserLocationUseCaseMock!
    
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
        getUserLocationUseCaseMock = GetUserLocationUseCaseMock()
        networkConnectionMonitorUseCaseSpy = NetworkConnectionMonitorUseCaseSpy()
        
        dependenciesContainerDummy[\.getObservedStationsUseCase] = getObservedStationsUseCaseSpy
        dependenciesContainerDummy[\.fetchAllStationsUseCase] = fetchAllStationsUseCaseSpy
        dependenciesContainerDummy[\.findTheNearestStationUseCase] = findTheNearestStationUseCaseSpy
        dependenciesContainerDummy[\.getUserLocationUseCase] = getUserLocationUseCaseMock
        dependenciesContainerDummy[\.networkConnectionMonitorUseCase] = networkConnectionMonitorUseCaseSpy
        
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
        networkConnectionMonitorUseCaseSpy.isConnectionSatisfiedReturnValue = true
        
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
        networkConnectionMonitorUseCaseSpy.isConnectionSatisfiedReturnValue = true
        
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
        networkConnectionMonitorUseCaseSpy.isConnectionSatisfiedReturnValue = true
        
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
        networkConnectionMonitorUseCaseSpy.isConnectionSatisfiedReturnValue = true
        
        fetchAllStationsUseCaseSpy.fetchStationsResult = .failure(ErrorDummy())
        getObservedStationsUseCaseSpy.fetchStationsResult = .success([])
        
        var error: Error?
        
        sut.errorSubject
            .sink {
                error = $0
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
        XCTAssertNotNil(error as? ErrorDummy)
    }
    
    @MainActor
    func testFetchStationsWhenFetchingObservedStationsFailed() {
        // Given
        networkConnectionMonitorUseCaseSpy.isConnectionSatisfiedReturnValue = true
        
        fetchAllStationsUseCaseSpy.fetchStationsResult = .success([])
        getObservedStationsUseCaseSpy.fetchStationsResult = .failure(ErrorDummy())
        
        var error: Error?
        
        sut.errorSubject
            .sink {
                error = $0
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
        XCTAssertNotNil(error as? ErrorDummy)
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
    func testFindTheNearestStationWhenLocationServicesNotAvailable() {
        // Given
        getUserLocationUseCaseMock.checkLocationServicesAvailabilityThrowError = .authorizationRestricted
        
        var error: Error?
        
        sut.errorSubject
            .sink {
                error = $0
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
        
        XCTAssertEqual(error as? UserLocationServicesError, .authorizationRestricted)
    }
    
    @MainActor
    func testFindTheNearestStationWhenFailure() {
        // Given
        findTheNearestStationUseCaseSpy.findStationsResult = .failure(ErrorDummy())
        
        var error: Error?
        
        sut.errorSubject
            .sink {
                error = $0
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
        
        XCTAssertNotNil(error as? ErrorDummy)
    }
    
    // MARK: track User Location
    
    @MainActor
    func testStartTrackingUserLocation() {
        // Given
        let location1 = Location(latitude: 1, longitude: 1)
        let location2 = Location(latitude: 2, longitude: 2)
        
        var userLocations: [Location] = []
        
        expectation.expectedFulfillmentCount = 2
        
        sut.$userLocation
            .dropFirst()
            .compactMap { $0 }
            .sink {
                userLocations.append($0)
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        getUserLocationUseCaseMock.streamLocationHandler = {
            self.getUserLocationUseCaseMock.locationStremSubject.send(location1)
            self.getUserLocationUseCaseMock.locationStremSubject.send(location2)
        }
        
        // When
        sut.startTrackingUserLocation()
        
        // Then
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(userLocations, [location1, location2])
        XCTAssertEqual(getUserLocationUseCaseMock.events, [
            .checkLocationServicesAvailability,
            .streamLocation
        ])
        
        // Given
        expectation = XCTestExpectation()
        getUserLocationUseCaseMock.expectation = expectation
        getUserLocationUseCaseMock.events.removeAll()
        
        // When
        sut.stopTrackingUserLocation()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(getUserLocationUseCaseMock.events, [
            .streamLocationFinish
        ])
    }
    
    @MainActor
    func testStartTrackingUserLocationWhenLocationServicesNotAvailable() {
        // Given
        getUserLocationUseCaseMock.checkLocationServicesAvailabilityThrowError = .authorizationDenied
        
        var error: Error?
        
        sut.errorSubject
            .sink {
                error = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.startTrackingUserLocation()
        
        // Then
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(error as? UserLocationServicesError, .authorizationDenied)
        XCTAssertNil(sut.userLocation)
        XCTAssertEqual(getUserLocationUseCaseMock.events, [.checkLocationServicesAvailability])
    }
    
    @MainActor
    func testStartTrackingUserLocationWhenFailure() {
        // Given
        expectation.expectedFulfillmentCount = 2
        
        var location: Location?
        var error: Error?
        
        sut.errorSubject
            .sink {
                error = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.$userLocation
            .dropFirst()
            .sink {
                location = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        getUserLocationUseCaseMock.streamLocationHandler = {
            self.getUserLocationUseCaseMock.locationStremSubject.send(completion: .failure(ErrorDummy()))
        }
        
        // When
        sut.startTrackingUserLocation()
        
        // Then
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(getUserLocationUseCaseMock.events, [
            .checkLocationServicesAvailability,
            .streamLocation
        ])
        XCTAssertNil(location)
        XCTAssertNotNil(error as? ErrorDummy)
    }
}

extension AddObservedStationMapModel.StationAnnotation: @retroactive Equatable, @retroactive Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.station == rhs.station && lhs.isStationObserved == rhs.isStationObserved
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(station.id)
    }
}
