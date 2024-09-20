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
    
    private var giosApiRepositorySpy: GIOSApiRepositorySpy!
    
    override func setUp() {
        super.setUp()
        
        sut = FetchAllStationsUseCase()
        
        giosApiRepositorySpy = GIOSApiRepositorySpy()
        
        dependenciesContainerDummy[\.stationsNetworkMapper] = StationsNetworkMapperFake()
        dependenciesContainerDummy[\.giosApiRepository] = giosApiRepositorySpy
    }
    
    func testFetch() async throws {
        // Given
        let stations: [Station] = [.dummy(id: 1), .dummy(id: 2)]
        
        giosApiRepositorySpy.fetchResult = .success(stations)
        
        // When
        let fetchedStations = try await sut.fetch()
        
        // Then
        XCTAssertEqual(fetchedStations, stations)
        XCTAssertEqual(giosApiRepositorySpy.events, [
            .fetch(
                String(describing: [Station].self),
                Endpoint.Stations.get.urlRequest!,
                .cacheIfPossible
            )
        ])
    }
    
    func testFetchWhenFailure() async {
        // Given
        giosApiRepositorySpy.fetchResult = .failure(ErrorDummy())
        
        do {
            // When
            _ = try await sut.fetch()
            XCTFail("fetch should have thrown an error!")
        } catch {
            // Then
            XCTAssertTrue(error is ErrorDummy)
            XCTAssertEqual(giosApiRepositorySpy.events, [
                .fetch(
                    String(describing: [Station].self),
                    Endpoint.Stations.get.urlRequest!,
                    .cacheIfPossible
                )
            ])
        }
    }
}
