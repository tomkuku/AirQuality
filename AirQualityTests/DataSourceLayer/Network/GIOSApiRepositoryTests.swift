//
//  GIOSApiRepositoryTests.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 04/05/2024.
//

import Foundation
import XCTest

@testable import AirQuality

final class GIOSApiRepositoryTest: BaseTestCase {
    
    private var sut: GIOSApiRepository!
    
    private var networkMapperSpy: NetworkMapperSpy!
    private var httpDataSourceMock: HTTPDataSourceMock!
    private var cacheDataSourceSpy: CacheDataSourceSpy!
    private var giosApiV1RepositorySpy: GIOSApiV1RepositorySpy!
    private var sensorsNetworkMapperSpy: SensorsNetworkMapperSpy!
    private var measurementsNetworkMapperSpy: SensorMeasurementNetworkMapperSpy!
    
    private var dateFormatter: DateFormatter!
    
    override func setUp() {
        super.setUp()
        
        networkMapperSpy = NetworkMapperSpy()
        httpDataSourceMock = HTTPDataSourceMock()
        cacheDataSourceSpy = CacheDataSourceSpy()
        giosApiV1RepositorySpy = GIOSApiV1RepositorySpy()
        
        sensorsNetworkMapperSpy = SensorsNetworkMapperSpy()
        measurementsNetworkMapperSpy = SensorMeasurementNetworkMapperSpy()
        
        dependenciesContainerDummy[\.giosApiV1Repository] = giosApiV1RepositorySpy
        dependenciesContainerDummy[\.cacheDataSource] = cacheDataSourceSpy
        dependenciesContainerDummy[\.sensorMeasurementsNetworkMapper] = measurementsNetworkMapperSpy
        dependenciesContainerDummy[\.sensorsNetworkMapper] = sensorsNetworkMapperSpy
        
        sut = GIOSApiRepository(httpDataSource: httpDataSourceMock)
        
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    // MARK: fetch
    
    func testFetchWhenSuccess() async throws {
        // Given
        let data = """
        [
            {
                "name": "James"
            },
            {
                "name": "Mike"
            }
        ]
        """.data(using: .utf8)!
        
        httpDataSourceMock.requestDataResult = .success(data)
        
        networkMapperSpy.mapResult = .success([.init(name: "Jack")])
        
        // When
        let objects = try await sut.fetch(
            mapper: networkMapperSpy,
            endpoint: EndpointFake(),
            source: .remote
        )
        
        // Then
        XCTAssertEqual(objects.first?.name, "Jack")
        XCTAssertEqual(networkMapperSpy.events, [.map])
        XCTAssertEqual(networkMapperSpy.inputs, [.init(name: "James"), .init(name: "Mike")])
    }
    
    func testFetchWhenNetworkDataSourceFailure() async {
        // Given
        httpDataSourceMock.requestDataResult = .failure(ErrorDummy())
        
        // When
        do {
            _ = try await sut.fetch(
                mapper: networkMapperSpy,
                endpoint: EndpointFake(),
                source: .cacheIfPossible
            )
            XCTFail("Fetch should have throw!")
        } catch {
            // Then
            XCTAssertTrue(error is ErrorDummy)
        }
    }
    
    func testFetchWhenMappingFailure() async {
        // Given
        let data = """
        [
            {
                "name": "James"
            },
            {
                "name": "Mike"
            }
        ]
        """.data(using: .utf8)!
        
        httpDataSourceMock.requestDataResult = .success(data)
        
        networkMapperSpy.mapResult = .failure(ErrorDummy())
        
        // When
        do {
            _ = try await sut.fetch(
                mapper: networkMapperSpy,
                endpoint: EndpointFake(),
                source: .cacheIfPossible
            )
            XCTFail("Fetch should have throw!")
        } catch {
            // Then
            XCTAssertTrue(error is ErrorDummy)
        }
    }
    
    // MARK: fetchSensors
    
    func testFetchSensors() async throws {
        // Given
        let sensorsData = """
        [
            {
                "id": 1,
                "param": {
                    "idParam": 3
                }
            },
            {
                "id": 2,
                "param": {
                    "idParam": 69
                }
            }
        ]
        """.data(using: .utf8)!
        
        httpDataSourceMock.requestDataResult = .success(sensorsData)
        
        let expectedFirstSensor = Sensor(
            id: 1,
            param: .pm10,
            measurements: [
                SensorMeasurement(value: 1.1, date: dateFormatter.date(from: "2024-06-17 15:00:00")!),
                SensorMeasurement(value: 1.2, date: dateFormatter.date(from: "2024-06-17 14:00:00")!)
            ]
        )
        
        let expectedSecondSensor = Sensor(
            id: 2,
            param: .pm25,
            measurements: [
                SensorMeasurement(value: 2.1, date: dateFormatter.date(from: "2024-06-17 15:00:00")!),
                SensorMeasurement(value: 2.2, date: dateFormatter.date(from: "2024-06-17 14:00:00")!)
            ]
        )
        
        giosApiV1RepositorySpy.fetchResultClosure = { request in
            if request.urlRequest == Endpoint.Measurements.get(1).urlRequest {
                return .success([
                    MeasurementNetworkModel(date: "2024-06-17 15:00:00", value: 1.1),
                    MeasurementNetworkModel(date: "2024-06-17 14:00:00", value: 1.2)
                ])
            } else if request.urlRequest == Endpoint.Measurements.get(2).urlRequest {
                return .success([
                    MeasurementNetworkModel(date: "2024-06-17 15:00:00", value: 2.1),
                    MeasurementNetworkModel(date: "2024-06-17 14:00:00", value: 2.2)
                ])
            }
            
            XCTFail("Unhandled request!")
            return nil
        }
        
        // When
        let sensors = try await sut.fetchSensors(for: 1)
        
        // Then
        let firstSensor = sensors.first(where: { $0.id == 1 })
        let secondSensor = sensors.first(where: { $0.id == 2 })
        
        XCTAssertEqual(sensors.count, 2)
        XCTAssertEqual(firstSensor, expectedFirstSensor)
        XCTAssertEqual(secondSensor, expectedSecondSensor)
        XCTAssertEqual(httpDataSourceMock.events, [.requestData(Endpoint.Sensors.get(1))])
        XCTAssertEqual(Set(giosApiV1RepositorySpy.events), Set([
            .fetch(SensorsNetworkMapper(), Endpoint.Measurements.get(1), "Lista danych pomiarowych"),
            .fetch(SensorsNetworkMapper(), Endpoint.Measurements.get(2), "Lista danych pomiarowych")
        ]))
        XCTAssertEqual(Set(sensorsNetworkMapperSpy.events), Set([
            .map(SensorNetworkModel(id: 1, param: .init(idParam: 3)), expectedFirstSensor.param, expectedFirstSensor.measurements),
            .map(SensorNetworkModel(id: 2, param: .init(idParam: 2)), expectedSecondSensor.param, expectedSecondSensor.measurements)
        ]))
        XCTAssertEqual(Set(measurementsNetworkMapperSpy.events), Set([
            .map([.init(date: "2024-06-17 15:00:00", value: 1.1), .init(date: "2024-06-17 14:00:00", value: 1.2)]),
            .map([.init(date: "2024-06-17 15:00:00", value: 2.1), .init(date: "2024-06-17 14:00:00", value: 2.2)])
        ]))
    }
    
    func testFetchSensorsWhenFetchingSensorsFailed() async throws {
        // Given
        httpDataSourceMock.requestDataResult = .failure(ErrorDummy())
        
        giosApiV1RepositorySpy.fetchResultClosure = { request in
            if request.urlRequest == Endpoint.Measurements.get(1).urlRequest {
                return .success([
                    MeasurementNetworkModel(date: "2024-06-17 15:00:00", value: 1.1),
                    MeasurementNetworkModel(date: "2024-06-17 14:00:00", value: 1.2)
                ])
            } else if request.urlRequest == Endpoint.Measurements.get(2).urlRequest {
                return .success([
                    MeasurementNetworkModel(date: "2024-06-17 15:00:00", value: 2.1),
                    MeasurementNetworkModel(date: "2024-06-17 14:00:00", value: 2.2)
                ])
            }
            
            XCTFail("Unhandled request!")
            return nil
        }
        
        do {
            // When
            _ = try await sut.fetchSensors(for: 1)
            XCTFail("fetchSensors should have thrown an error!")
        } catch {
            // Then
            XCTAssertTrue(error is ErrorDummy)
            XCTAssertEqual(httpDataSourceMock.events, [.requestData(Endpoint.Sensors.get(1))])
            XCTAssertTrue(giosApiV1RepositorySpy.events.isEmpty)
            XCTAssertTrue(sensorsNetworkMapperSpy.events.isEmpty)
            XCTAssertTrue(measurementsNetworkMapperSpy.events.isEmpty)
        }
    }
    
    func testFetchSensorsWhenFetchingMeasurementsForOneSensorFailed() async throws {
        // Given
        let sensorsData = """
        [
            {
                "id": 1,
                "param": {
                    "idParam": 3
                }
            },
            {
                "id": 2,
                "param": {
                    "idParam": 69
                }
            }
        ]
        """.data(using: .utf8)!
        
        httpDataSourceMock.requestDataResult = .success(sensorsData)
        
        giosApiV1RepositorySpy.fetchResultClosure = { request in
            if request.urlRequest == Endpoint.Measurements.get(1).urlRequest {
                return .success([
                    MeasurementNetworkModel(date: "2024-06-17 15:00:00", value: 1.1),
                    MeasurementNetworkModel(date: "2024-06-17 14:00:00", value: 1.2)
                ])
            } else if request.urlRequest == Endpoint.Measurements.get(2).urlRequest {
                return .failure(ErrorDummy())
            }
            
            XCTFail("Unhandled request!")
            return nil
        }
        
        do {
            // When
            _ = try await sut.fetchSensors(for: 1)
            XCTFail("fetchSensors should have thrown an error!")
        } catch {
            // Then
            XCTAssertTrue(error is ErrorDummy)
            XCTAssertEqual(httpDataSourceMock.events, [.requestData(Endpoint.Sensors.get(1))])
            XCTAssertTrue(giosApiV1RepositorySpy.events.contains(
                .fetch(SensorsNetworkMapper(), Endpoint.Measurements.get(1), "Lista danych pomiarowych")
            ))
            XCTAssertTrue(sensorsNetworkMapperSpy.events.isEmpty)
            XCTAssertEqual(Set(measurementsNetworkMapperSpy.events), Set([
                .map([.init(date: "2024-06-17 15:00:00", value: 1.1), .init(date: "2024-06-17 14:00:00", value: 1.2)])
            ]))
        }
    }
    
    func testFetchSensorsWhenNoParamForOneSensor() async throws {
        // Given
        let sensorsData = """
        [
            {
                "id": 1,
                "param": {
                    "idParam": 3
                }
            },
            {
                "id": 2,
                "param": {
                    "idParam": 22
                }
            }
        ]
        """.data(using: .utf8)!
        
        let expectedSensor = Sensor(
            id: 1,
            param: .pm10,
            measurements: [
                SensorMeasurement(value: 1.1, date: dateFormatter.date(from: "2024-06-17 15:00:00")!),
                SensorMeasurement(value: 1.2, date: dateFormatter.date(from: "2024-06-17 14:00:00")!)
            ]
        )
        
        httpDataSourceMock.requestDataResult = .success(sensorsData)
        
        giosApiV1RepositorySpy.fetchResultClosure = { request in
            if request.urlRequest == Endpoint.Measurements.get(1).urlRequest {
                return .success([
                    MeasurementNetworkModel(date: "2024-06-17 15:00:00", value: 1.1),
                    MeasurementNetworkModel(date: "2024-06-17 14:00:00", value: 1.2)
                ])
            } else if request.urlRequest == Endpoint.Measurements.get(2).urlRequest {
                return .success([
                    MeasurementNetworkModel(date: "2024-06-17 15:00:00", value: 2.1),
                    MeasurementNetworkModel(date: "2024-06-17 14:00:00", value: 2.2)
                ])
            }
            
            XCTFail("Unhandled request!")
            return nil
        }
        
        // When
        let sensors = try await sut.fetchSensors(for: 1)
        
        // Then
        XCTAssertEqual(sensors.count, 1)
        XCTAssertEqual(sensors.first, expectedSensor)
        XCTAssertEqual(httpDataSourceMock.events, [.requestData(Endpoint.Sensors.get(1))])
        XCTAssertEqual(giosApiV1RepositorySpy.events, [
            .fetch(SensorsNetworkMapper(), Endpoint.Measurements.get(1), "Lista danych pomiarowych")
        ])
        XCTAssertEqual(sensorsNetworkMapperSpy.events, [
            .map(SensorNetworkModel(id: 1, param: .init(idParam: 3)), expectedSensor.param, expectedSensor.measurements)
        ])
        XCTAssertEqual(Set(measurementsNetworkMapperSpy.events), Set([
            .map([.init(date: "2024-06-17 15:00:00", value: 1.1), .init(date: "2024-06-17 14:00:00", value: 1.2)])
        ]))
    }
    
    // MARK: DomainModelFake
    
    private struct DomainModelFake {
        let name: String
    }
    
    // MARK: NetworkModelFake
    
    private struct NetworkModelFake: Decodable, Equatable {
        let name: String
    }
    
    // MARK: NetworkMapperSpy
    
    private final class NetworkMapperSpy: NetworkMapperProtocol, @unchecked Sendable {
        enum Event {
            case map
        }
        
        var events: [Event] = []
        
        var mapResult: Result<[DomainModelFake], Error> = .failure(ErrorDummy())
        var inputs: [NetworkModelFake]?
        
        func map(_ input: [NetworkModelFake]) throws -> [DomainModelFake] {
            events.append(.map)
            inputs = input
            
            switch mapResult {
            case .success(let models):
                return models
            case .failure(let error):
                throw error
            }
        }
    }
}
