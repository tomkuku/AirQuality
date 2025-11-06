//
//  GetSensorsUseCaseTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 12/05/2024.
//

import XCTest

@testable import AirQuality

final class GetSensorsUseCaseTests: BaseTestCase, @unchecked Sendable {
    
    private var sut: GetSensorsUseCase!
    
    private var giosApiV1RepositorySpy: GIOSApiV1RepositorySpy!
    
    override func setUp() {
        super.setUp()
        
        giosApiV1RepositorySpy = GIOSApiV1RepositorySpy()
        
        sut = GetSensorsUseCase()
        
        dependenciesContainerDummy[\.giosApiV1Repository] = giosApiV1RepositorySpy
        dependenciesContainerDummy[\.sensorMeasurementsNetworkMapper] = SensorMeasurementNetworkMapper()
        dependenciesContainerDummy[\.dtoSensorsNetworkMapper] = DTOSensorsNetworkMapper()
        dependenciesContainerDummy[\.sensorMeasurementDataFormatter] = SensorMeasurementDataFormatter()
    }
    
    // MARK: - getSensors
    
    func testGetSensorsWhenSingleSensorWithMeasurements() async throws {
        // Given
        let stationId = 1
        let sensorId = 100
        let paramId = ParamType.pm10.rawValue
        let param = Param.pm10
        let measurements: [SensorMeasurement] = [
            SensorMeasurement.dummy(date: "2024-06-25 15:00", value: 10.5),
            SensorMeasurement.dummy(date: "2024-06-25 14:00", value: 20.3)
        ]
        let expectedSensor = Sensor.dummy(id: sensorId, param: param, measurements: measurements)
        
        let dtoSensors: [DTO.Sensor] = [
            DTO.Sensor(id: sensorId, paramId: paramId)
        ]
        
        var fetchCallCount = 0
        
        giosApiV1RepositorySpy.fetchResultClosure = { endpoint in
            if endpoint is Endpoint.Sensors {
                return .success(dtoSensors)
            } else if endpoint is Endpoint.Measurements {
                fetchCallCount += 1
                return .success(measurements)
            }
            return .success([])
        }
        
        // When
        let result = try await sut.getSensors(for: stationId)
        
        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first, expectedSensor)
        XCTAssertEqual(fetchCallCount, 1)
        XCTAssertEqual(giosApiV1RepositorySpy.events.count, 2) // 1 for sensors, 1 for measurements
    }
    
    func testGetSensorsWhenMultipleSensorsWithMeasurements() async throws {
        // Given
        let stationId = 1
        let sensorId1 = 100
        let sensorId2 = 200
        let paramId1 = ParamType.pm10.rawValue
        let paramId2 = ParamType.pm25.rawValue
        let param1 = Param.pm10
        let param2 = Param.pm25
        let measurements1: [SensorMeasurement] = [
            SensorMeasurement.dummy(date: "2024-06-25 15:00", value: 10.5)
        ]
        let measurements2: [SensorMeasurement] = [
            SensorMeasurement.dummy(date: "2024-06-25 14:00", value: 20.3)
        ]
        
        let dtoSensors: [DTO.Sensor] = [
            DTO.Sensor(id: sensorId1, paramId: paramId1),
            DTO.Sensor(id: sensorId2, paramId: paramId2)
        ]
        
        var measurementsCallCount = 0
        
        giosApiV1RepositorySpy.fetchResultClosure = { endpoint in
            switch endpoint {
            case is Endpoint.Sensors:
                return .success(dtoSensors)
            case let measurementsEndpoint as Endpoint.Measurements:
                defer {
                    measurementsCallCount += 1
                }
                
                switch measurementsEndpoint {
                case .get(let sensorId) where sensorId == sensorId1:
                    return .success(measurements1)
                case .get(let sensorId) where sensorId == sensorId2:
                    return .success(measurements2)
                default:
                    return .success([])
                }
            default:
                return .success([])
            }
        }
        
        // When
        let result = try await sut.getSensors(for: stationId)
        
        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(measurementsCallCount, 2)
        XCTAssertEqual(giosApiV1RepositorySpy.events.count, 3) // 1 for sensors, 2 for measurements
        
        // Verify sensors are created correctly
        let sensor1 = result.first { $0.id == sensorId1 }
        XCTAssertNotNil(sensor1)
        XCTAssertEqual(sensor1?.param, param1)
        XCTAssertEqual(sensor1?.measurements, measurements1)
        
        let sensor2 = result.first { $0.id == sensorId2 }
        XCTAssertNotNil(sensor2)
        XCTAssertEqual(sensor2?.param, param2)
        XCTAssertEqual(sensor2?.measurements, measurements2)
    }
    
    func testGetSensorsWhenParamNotFound() async throws {
        // Given
        let stationId = 1
        let sensorId = 100
        let invalidParamId = 999 // Param that doesn't exist
        
        let dtoSensors: [DTO.Sensor] = [
            DTO.Sensor(id: sensorId, paramId: invalidParamId)
        ]
        
        giosApiV1RepositorySpy.fetchResultClosure = { endpoint in
            if endpoint is Endpoint.Sensors {
                return .success(dtoSensors)
            }
            return .success([])
        }
        
        // When
        let result = try await sut.getSensors(for: stationId)
        
        // Then - Sensor should be filtered out when param is not found
        XCTAssertEqual(result.count, 0)
        XCTAssertEqual(giosApiV1RepositorySpy.events.count, 1) // Only sensors fetch, no measurements fetch
    }
    
    func testGetSensorsWhenSomeParamsNotFound() async throws {
        // Given
        let stationId = 1
        let sensorId1 = 100
        let sensorId2 = 200
        let paramId1 = ParamType.pm10.rawValue
        let invalidParamId = 999
        let param1 = Param.pm10
        let measurements1: [SensorMeasurement] = [
            SensorMeasurement.dummy(date: "2024-06-25 15:00", value: 10.5)
        ]
        
        let dtoSensors: [DTO.Sensor] = [
            DTO.Sensor(id: sensorId1, paramId: paramId1),
            DTO.Sensor(id: sensorId2, paramId: invalidParamId)
        ]
        
        giosApiV1RepositorySpy.fetchResultClosure = { endpoint in
            if endpoint is Endpoint.Sensors {
                return .success(dtoSensors)
            } else if endpoint is Endpoint.Measurements {
                return .success(measurements1)
            }
            return .success([])
        }
        
        // When
        let result = try await sut.getSensors(for: stationId)
        
        // Then - Only sensor with valid param should be included
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, sensorId1)
        XCTAssertEqual(result.first?.param, param1)
        XCTAssertEqual(giosApiV1RepositorySpy.events.count, 2) // 1 for sensors, 1 for measurements (only valid sensor)
    }
    
    func testGetSensorsWhenNoSensors() async throws {
        // Given
        let stationId = 1
        let dtoSensors: [DTO.Sensor] = []
        
        giosApiV1RepositorySpy.fetchResultClosure = { endpoint in
            if endpoint is Endpoint.Sensors {
                return .success(dtoSensors)
            }
            return .success([])
        }
        
        // When
        let result = try await sut.getSensors(for: stationId)
        
        // Then
        XCTAssertEqual(result.count, 0)
        XCTAssertEqual(giosApiV1RepositorySpy.events.count, 1) // Only sensors fetch
    }
    
    func testGetSensorsWhenFetchingSensorsFailed() async throws {
        // Given
        let stationId = 1
        let expectedError = NSError(domain: "stub", code: 42)
        
        giosApiV1RepositorySpy.fetchResultClosure = { endpoint in
            if endpoint is Endpoint.Sensors {
                return .failure(expectedError)
            }
            return .success([])
        }
        
        // When & Then
        do {
            _ = try await sut.getSensors(for: stationId)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual((error as NSError).code, expectedError.code)
        }
        XCTAssertEqual(giosApiV1RepositorySpy.events.count, 1)
    }
    
    func testGetSensorsWhenFetchingMeasurementsFailed() async throws {
        // Given
        let stationId = 1
        let sensorId = 100
        let paramId = ParamType.pm10.rawValue
        let expectedError = NSError(domain: "stub", code: 42)
        
        let dtoSensors: [DTO.Sensor] = [
            DTO.Sensor(id: sensorId, paramId: paramId)
        ]
        
        giosApiV1RepositorySpy.fetchResultClosure = { endpoint in
            if endpoint is Endpoint.Sensors {
                return .success(dtoSensors)
            } else if endpoint is Endpoint.Measurements {
                return .failure(expectedError)
            }
            return .success([])
        }
        
        // When & Then
        do {
            _ = try await sut.getSensors(for: stationId)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual((error as NSError).code, expectedError.code)
        }
        XCTAssertEqual(giosApiV1RepositorySpy.events.count, 2) // 1 for sensors, 1 for measurements
    }
    
    func testGetSensorsWhenFetchingOneMeasurementFailed() async throws {
        // Given
        let stationId = 1
        let sensorId1 = 100
        let sensorId2 = 200
        let paramId1 = ParamType.pm10.rawValue
        let paramId2 = ParamType.pm25.rawValue
        let expectedError = NSError(domain: "stub", code: 42)
        let measurements2: [SensorMeasurement] = [
            SensorMeasurement.dummy(date: "2024-06-25 14:00", value: 20.3)
        ]
        
        let dtoSensors: [DTO.Sensor] = [
            DTO.Sensor(id: sensorId1, paramId: paramId1),
            DTO.Sensor(id: sensorId2, paramId: paramId2)
        ]
        
        var measurementsCallCount = 0
        
        giosApiV1RepositorySpy.fetchResultClosure = { endpoint in
            if endpoint is Endpoint.Sensors {
                return .success(dtoSensors)
            } else if endpoint is Endpoint.Measurements {
                defer {
                    measurementsCallCount += 1
                }
                
                if measurementsCallCount == 0 {
                    return .failure(expectedError)
                } else {
                    return .success(measurements2)
                }
            }
            return .success([])
        }
        
        // When & Then
        do {
            _ = try await sut.getSensors(for: stationId)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual((error as NSError).code, expectedError.code)
        }
        XCTAssertEqual(giosApiV1RepositorySpy.events.count, 3) // 1 for sensors, 2 for measurements
    }
    
    func testGetSensorsCallsCorrectEndpoints() async throws {
        // Given
        let stationId = 1
        let sensorId = 100
        let paramId = ParamType.pm10.rawValue
        let measurements: [SensorMeasurement] = [
            SensorMeasurement.dummy(date: "2024-06-25 15:00", value: 10.5)
        ]
        
        let dtoSensors: [DTO.Sensor] = [
            DTO.Sensor(id: sensorId, paramId: paramId)
        ]
        
        var capturedStationId: Int?
        var capturedSensorId: Int?
        
        giosApiV1RepositorySpy.fetchResultClosure = { endpoint in
            if let endpoint = endpoint as? Endpoint.Sensors {
                switch endpoint {
                case .get(let id):
                    capturedStationId = id
                }
                return .success(dtoSensors)
            } else if let endpoint = endpoint as? Endpoint.Measurements {
                switch endpoint {
                case .get(let id):
                    capturedSensorId = id
                }
                return .success(measurements)
            }
            return .success([])
        }
        
        // When
        _ = try await sut.getSensors(for: stationId)
        
        // Then
        XCTAssertEqual(capturedStationId, stationId)
        XCTAssertEqual(capturedSensorId, sensorId)
    }
}
