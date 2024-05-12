//
//  GetStationsUseCase.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 12/05/2024.
//

import XCTest

@testable import AirQuality

final class GetStationsUseCaseTests: XCTestCase {
    
    private var sut: GetStationsUseCase!
    
    private var giosApiRepositorySpy: GIOSApiRepositorySpy!
    
    override func setUp() {
        super.setUp()
        
        giosApiRepositorySpy = GIOSApiRepositorySpy()
        
        sut = GetStationsUseCase()
        
        let dependencies = AllDependenciesDummy(giosApiRepository: giosApiRepositorySpy)
        
        DependenciesContainerManager.container = dependencies
    }
    
    override func tearDown() {
        sut = nil
        
        giosApiRepositorySpy = nil
        
        super.tearDown()
    }
    
    func testGetStations() async throws {
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
    }
}

struct AllDependenciesDummy: AllDependencies {
    var giosApiRepository: GIOSApiRepositoryProtocol
}
