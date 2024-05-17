//
//  GetSensorsUseCaseTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 12/05/2024.
//

import XCTest

@testable import AirQuality

final class GetSensorsUseCaseTests: BaseTestCase {
    
    private var sut: GetSensorsUseCase!
    
    private var giosApiRepositorySpy: GIOSApiRepositorySpy!
    
    override func setUp() {
        super.setUp()
        
        giosApiRepositorySpy = GIOSApiRepositorySpy()
        
        sut = GetSensorsUseCase()
        
        dependenciesContainerDummy[\.giosApiRepository] = giosApiRepositorySpy
    }
    
    func testGetSensorsWhenSuccess() async throws {
        // Given
        let sensor1 = Sensor.dummy(id: 1)
        let sensor2 = Sensor.dummy(id: 2)
        
        giosApiRepositorySpy.fetchSensorsResult = .success([sensor1, sensor2])
        
        let id = 123
        
        // When
        let sensors = try await sut.getSensors(for: id)
        
        // Then
        XCTAssertEqual(giosApiRepositorySpy.events, [
            .fetchSensors(id)
        ])
        
        XCTAssertEqual(sensors, [sensor1, sensor2])
    }
    
    func testGetSensorsWhenFailure() async throws {
        // Given
        giosApiRepositorySpy.fetchSensorsResult = .failure(ErrorDummy())
        
        let id = 123
        
        // When
        do {
            _ = try await sut.getSensors(for: id)
            XCTFail("getSensors should have thrown!")
        } catch {
            XCTAssertTrue(error is ErrorDummy)
        }
        
        // Then
        XCTAssertEqual(giosApiRepositorySpy.events, [
            .fetchSensors(id)
        ])
    }
}
