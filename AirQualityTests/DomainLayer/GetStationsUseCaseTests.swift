//
//  GetStationsUseCase.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 12/05/2024.
//

import XCTest

@testable import AirQuality

final class GetStationsUseCaseTests: BaseTestCase {
    
    private var sut: GetStationsUseCase!
    
    private var giosApiRepositorySpy: GIOSApiRepositorySpy!
    
    override func setUp() {
        super.setUp()
        
        giosApiRepositorySpy = GIOSApiRepositorySpy()
        
        sut = GetStationsUseCase()
        
        dependenciesContainerDummy[\.giosApiRepository] = giosApiRepositorySpy
    }
    
    func testGetStationsWhenSuccess() async throws {
        // Given
        let station1 = Station.dummy(id: 1)
        let station2 = Station.dummy(id: 2)
        
        giosApiRepositorySpy.fetchResult = .success([station1, station2])
        
        // When
        let stations = try await sut.getAllStations()
        
        let expectedRequest = try Endpoint.Stations.get.asURLRequest()
        let expectedDomainModelName = String(describing: [Station].self)
        let expectedBodyContentDirName = "Lista stacji pomiarowych"
        
        // Then
        XCTAssertEqual(giosApiRepositorySpy.events, [
            .fetch(
                expectedDomainModelName,
                expectedRequest,
                expectedBodyContentDirName
            )
        ])
        XCTAssertEqual(stations, [station1, station2])
    }
    
    func testGetStationsWhenFailure() async throws {
        // Given
        giosApiRepositorySpy.fetchResult = .failure(ErrorDummy())
        
        let expectedRequest = try Endpoint.Stations.get.asURLRequest()
        let expectedDomainModelName = String(describing: [Station].self)
        let expectedBodyContentDirName = "Lista stacji pomiarowych"
        
        // When
        do {
            _ = try await sut.getAllStations()
            XCTFail("getAllStations should have thrown!")
        } catch {
            XCTAssertTrue(error is ErrorDummy)
        }
        
        // Then
        XCTAssertEqual(giosApiRepositorySpy.events, [
            .fetch(
                expectedDomainModelName,
                expectedRequest,
                expectedBodyContentDirName
            )
        ])
    }
}
