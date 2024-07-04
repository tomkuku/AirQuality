//
//  ParamsViewModelTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 03/07/2024.
//

import XCTest

@testable import AirQuality

final class ParamsViewModelTests: BaseTestCase, @unchecked Sendable {
    
    private var sut: ParamsViewModel!
    
    private var getStationSensorsParamsUseCaseSpy: GetStationSensorsParamsUseCaseSpy!
    private var station: Station!
    
    override func setUp() async throws {
        try await super.setUp()
        
        station = .dummy()
        
        getStationSensorsParamsUseCaseSpy = GetStationSensorsParamsUseCaseSpy()
        
        dependenciesContainerDummy[\.getStationSensorsParamsUseCase] = getStationSensorsParamsUseCaseSpy
        
        await MainActor.run {
            sut = ParamsViewModel(station: station)
        }
    }
    
    @MainActor
    func testFetchParamsMeasuredByStation() {
        // Given
        let expectedParams: [Param] = [.c6h6, .pm10, .o3]
        
        var params: [Param]?
        
        getStationSensorsParamsUseCaseSpy.getResult = .success(expectedParams)
        
        sut.$params
            .dropFirst()
            .sink {
                params = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.fetchParamsMeasuredByStation()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(getStationSensorsParamsUseCaseSpy.events, [.get(station.id)])
        XCTAssertEqual(expectedParams, params)
        XCTAssertFalse(sut.isLoading)
    }
    
    @MainActor
    func testFetchParamsMeasuredByStationWhenFailure() {
        // Given
        getStationSensorsParamsUseCaseSpy.getResult = .failure(ErrorDummy())
        
        var error: Error?
        
        sut.$params
            .dropFirst()
            .sink { _ in
                XCTFail("Params should not publish any value!")
            }
            .store(in: &cancellables)
        
        sut.errorSubject
            .sink {
                error = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.fetchParamsMeasuredByStation()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(getStationSensorsParamsUseCaseSpy.events, [.get(station.id)])
        XCTAssertNil(sut.params)
        XCTAssertTrue(sut.isLoading)
        XCTAssertNotNil(error as? ErrorDummy)
    }
}
