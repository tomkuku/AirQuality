//
//  AddObservedStationUseCaseTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 16/06/2024.
//

import XCTest

@testable import AirQuality

final class AddObservedStationUseCaseTests: BaseTestCase {
    
    private var sut: AddObservedStationUseCase!
    private var localDatabaseRepositorySpy: LocalDatabaseRepositorySpy!
    
    override func setUp() {
        super.setUp()
        
        sut = AddObservedStationUseCase()
        
        localDatabaseRepositorySpy = LocalDatabaseRepositorySpy()
        
        dependenciesContainerDummy[\.stationsLocalDatabaseMapper] = StationsLocalDatabaseMapperDummy()
        dependenciesContainerDummy[\.localDatabaseRepository] = localDatabaseRepositorySpy
    }
    
    func testAdd() async throws {
        // Given
        let station = Station.dummy()
        
        // When
        try await sut.add(station: station)
        
        // Given
        XCTAssertEqual(localDatabaseRepositorySpy.events, [.insert])
    }
    
    func testAddWhenFialure() async {
        // Given
        let station = Station.dummy()
        localDatabaseRepositorySpy.insertThrowError = ErrorDummy()
        
        do {
            // When
            try await sut.add(station: station)
            XCTFail("add should have thrown an error!")
        } catch {
            // Then
            XCTAssertTrue(error is ErrorDummy)
        }
    }
}
