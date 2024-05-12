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
        
        giosApiRepositorySpy.fetchResult = .success([sensor1, sensor2])
        
        let id = 123
        
        // When
        let sensors = try await sut.getSensors(for: id)
        
        let expectedRequest = try Endpoint.Sensors.get(id).asURLRequest()
        let expectedDomainModelName = String(describing: [Sensor].self)
        let expectedBodyContentDirName = "Lista stanowisk pomiarowych dla podanej stacji"
        
        // Then
        XCTAssertEqual(giosApiRepositorySpy.events, [
            .fetch(
                expectedDomainModelName,
                expectedRequest,
                expectedBodyContentDirName
            )
        ])
        
        XCTAssertEqual(sensors, [sensor1, sensor2])
    }
    
    func testGetSensorsWhenFailure() async throws {
        // Given
        giosApiRepositorySpy.fetchResult = .failure(ErrorDummy())
        
        let id = 123
        
        let expectedRequest = try Endpoint.Sensors.get(id).asURLRequest()
        let expectedDomainModelName = String(describing: [Sensor].self)
        let expectedBodyContentDirName = "Lista stanowisk pomiarowych dla podanej stacji"
        
        // When
        do {
            _ = try await sut.getSensors(for: id)
            XCTFail("getSensors should have thrown!")
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
