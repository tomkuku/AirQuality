//
//  DeleteObservedStationUseCaseTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 16/06/2024.
//

import XCTest

@testable import AirQuality

final class DeleteObservedStationUseCaseTests: BaseTestCase {
    
    private var sut: DeleteObservedStationUseCase!
    private var localDatabaseRepositorySpy: LocalDatabaseRepositorySpy!
    
    override func setUp() {
        super.setUp()
        
        sut = DeleteObservedStationUseCase()
        
        localDatabaseRepositorySpy = LocalDatabaseRepositorySpy()
        
        dependenciesContainerDummy[\.stationsLocalDatabaseMapper] = StationsLocalDatabaseMapperDummy()
        dependenciesContainerDummy[\.localDatabaseRepository] = localDatabaseRepositorySpy
    }
    
    func testDelete() async throws {
        // Given
        let station = Station.dummy()
        
        // When
        try await sut.delete(station: station)
        
        // Given
        XCTAssertEqual(localDatabaseRepositorySpy.events, [.delete])
    }
    
    func testDeleteWhenFialure() async {
        // Given
        let station = Station.dummy()
        localDatabaseRepositorySpy.deleteThrowError = ErrorDummy()
        
        do {
            // When
            try await sut.delete(station: station)
            XCTFail("add should have thrown an error!")
        } catch {
            // Then
            XCTAssertTrue(error is ErrorDummy)
            XCTAssertEqual(localDatabaseRepositorySpy.events, [.delete])
        }
    }
}
