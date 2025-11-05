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
        giosApiRepositorySpy.totalPages = 1
        giosApiRepositorySpy.fetchResultClosure = { _ in
            .success([StationNetworkModel]() as [Any])
        }
        
        // When
        let result = try await sut.fetch()
        
        // Then
        XCTAssertTrue(result.isEmpty)
        XCTAssertEqual(giosApiRepositorySpy.events.count, 1)
    }
    
    func testFetchWhenSinglePageWithStations() async throws {
        // Given
        let stationsPage: [Station] = [
            Station(
                id: 1,
                latitude: 50.0,
                longitude: 20.0,
                cityName: "City 1",
                province: "Province 1",
                street: "Main St"
            )
        ]
        
        giosApiRepositorySpy.totalPages = 1
        giosApiRepositorySpy.fetchResultClosure = { _ in
            .success(stationsPage)
        }
        
        // When
        let result = try await sut.fetch()
        
        // Then
        XCTAssertEqual(result, stationsPage)
        XCTAssertEqual(giosApiRepositorySpy.events.count, 1)
    }
    
    func testFetchWhenMultiplePages() async throws {
        // Given
        let stationsPage1: [Station] = [
            Station(
                id: 1,
                latitude: 1.0,
                longitude: 2.0,
                cityName: "C1",
                province: "Prov1",
                street: "Street 1"
            )
        ]
        let stationsPage2: [Station] = [
            Station(
                id: 2,
                latitude: 3.0,
                longitude: 4.0,
                cityName: "C2",
                province: "Prov2",
                street: "Street 2"
            )
        ]
        
        var currentPage = 0
        
        giosApiRepositorySpy.fetchResultClosure = { [unowned self] _ in
            defer {
                currentPage += 1
            }
            
            if currentPage == 0 {
                self.giosApiRepositorySpy.totalPages = 2
                return .success(stationsPage1)
            } else {
                self.giosApiRepositorySpy.totalPages = 2
                return .success(stationsPage2)
            }
        }
        
        // When
        let result = try await sut.fetch()
        
        // Then
        XCTAssertEqual(result, stationsPage1 + stationsPage2)
        XCTAssertEqual(giosApiRepositorySpy.events.count, 2)
    }
    
    func testFetchWhenRepositoryFails() async throws {
        // Given
        let expectedError = NSError(domain: "stub", code: 42)
        
        giosApiRepositorySpy.fetchResultClosure = { _ in
            .failure(expectedError)
        }
        giosApiRepositorySpy.totalPages = 1
        
        // When & Then
        do {
            _ = try await sut.fetch()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual((error as NSError).code, expectedError.code)
        }
        XCTAssertEqual(giosApiRepositorySpy.events.count, 1)
    }
}
