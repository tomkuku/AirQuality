//
//  FetchAllStationsUseCaseTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 16/06/2024.
//

import XCTest

@testable import AirQuality

final class FetchAllStationsUseCaseTests: BaseTestCase {
    
    private var sut: FetchAllStationsUseCase!
    
    private var giosApiRepositorySpy: GIOSApiV1RepositorySpy!
    private var stationsNetworkMapperMock: StationsNetworkMapperMock!
    
    override func setUp() {
        super.setUp()
        
        giosApiRepositorySpy = GIOSApiV1RepositorySpy()
        
        dependenciesContainerDummy[\.stationsNetworkMapper] = StationsNetworkMapper()
        dependenciesContainerDummy[\.giosApiV1Repository] = giosApiRepositorySpy
        
        sut = FetchAllStationsUseCase()
    }
    
    // MARK: - fetch
    
    func testFetchWhenNoStations() async throws {
        // Given
        giosApiRepositorySpy.fetchAllStationsResult = .success([])
        
        // When
        let result = try await sut.fetch()
        
        // Then
        XCTAssertTrue(result.isEmpty)
        XCTAssertEqual(giosApiRepositorySpy.events.count, 1)
        XCTAssertEqual(giosApiRepositorySpy.events.first, .fetchAllStations())
    }
    
    func testFetchWhenSinglePageWithStations() async throws {
        // Given
        let stations: [Station] = [
            Station(
                id: 1,
                latitude: 50.0,
                longitude: 20.0,
                cityName: "City 1",
                province: "Province 1",
                street: "Main St"
            )
        ]
        
        giosApiRepositorySpy.fetchAllStationsResult = .success(stations)
        
        // When
        let result = try await sut.fetch()
        
        // Then
        XCTAssertEqual(result, stations)
        XCTAssertEqual(giosApiRepositorySpy.events.count, 1)
        XCTAssertEqual(giosApiRepositorySpy.events.first, .fetchAllStations())
    }
    
    func testFetchWhenMultipleStations() async throws {
        // Given
        let stations: [Station] = [
            Station(
                id: 1,
                latitude: 1.0,
                longitude: 2.0,
                cityName: "C1",
                province: "Prov1",
                street: "Street 1"
            ),
            Station(
                id: 2,
                latitude: 3.0,
                longitude: 4.0,
                cityName: "C2",
                province: "Prov2",
                street: "Street 2"
            )
        ]
        
        giosApiRepositorySpy.fetchAllStationsResult = .success(stations)
        
        // When
        let result = try await sut.fetch()
        
        // Then
        XCTAssertEqual(result, stations)
        XCTAssertEqual(giosApiRepositorySpy.events.count, 1)
        XCTAssertEqual(giosApiRepositorySpy.events.first, .fetchAllStations())
    }
    
    func testFetchWhenRepositoryFails() async throws {
        // Given
        let expectedError = NSError(domain: "stub", code: 42)
        giosApiRepositorySpy.fetchAllStationsResult = .failure(expectedError)
        
        // When & Then
        do {
            _ = try await sut.fetch()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual((error as NSError).code, expectedError.code)
        }
        XCTAssertEqual(giosApiRepositorySpy.events.count, 1)
        XCTAssertEqual(giosApiRepositorySpy.events.first, .fetchAllStations())
    }
}
