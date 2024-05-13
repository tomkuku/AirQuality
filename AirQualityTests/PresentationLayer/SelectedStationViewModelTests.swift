//
//  SelectedStationViewModel.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 13/05/2024.
//

import XCTest
import Combine
import Alamofire

@testable import AirQuality

final class SelectedStationViewModelTests: BaseTestCase {
    
    private var sut: SelectedStationViewModel!
    
    private var getSensorsUseCaseSpy: GetSensorsUseCaseSpy!
    private var getSensorMeasurementsUseCaseSpy: GetSensorMeasurementsUseCaseSpy!
    
    private var stationDummy: Station!
    private var cancellables: Set<AnyCancellable>!
    private var dateFormatter: DateFormatter!
    
    override func setUp() {
        super.setUp()
        
        DependenciesContainerManager.container = appDependencies
        
        stationDummy = .dummy()
        cancellables = Set<AnyCancellable>()
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        getSensorsUseCaseSpy = GetSensorsUseCaseSpy()
        getSensorMeasurementsUseCaseSpy = GetSensorMeasurementsUseCaseSpy()
        
        sut = SelectedStationViewModel(
            station: stationDummy,
            getSensorsUseCase: getSensorsUseCaseSpy,
            getSensorMeasurementsUseCase: getSensorMeasurementsUseCaseSpy
        )
    }
    
    func testFomattedStationAddress() {
        // When
        let fomattedStationAddress = sut.fomattedStationAddress
        
        // Then
        XCTAssertEqual(fomattedStationAddress, stationDummy.cityName + " " + stationDummy.street!)
    }
    
    func testFomattedStationAddressWhenStationsAddressHasNoStreet() {
        // Given
        stationDummy = .dummy(street: nil)
        
        sut = SelectedStationViewModel(
            station: stationDummy,
            getSensorsUseCase: getSensorsUseCaseSpy,
            getSensorMeasurementsUseCase: getSensorMeasurementsUseCaseSpy
        )
        
        // When
        let fomattedStationAddress = sut.fomattedStationAddress
        
        // Then
        XCTAssertEqual(fomattedStationAddress, stationDummy.cityName + " ")
    }
    
    func testFetchSensorsForStationWhenSuccess() async throws {
        // Given
        let expectedMeasuremntDateString = "2024-06-23 15:20"
        let expectedMeasuremntDate = dateFormatter.date(from: expectedMeasuremntDateString)!
        
        let sensor1 = Sensor.dummy(id: 1)
        let sensor2 = Sensor.dummy(id: 2)
        
        getSensorsUseCaseSpy.fetchResult = .success([sensor1, sensor2])
        
        let measurement1 = AirQuality.Measurement.dummy(date: expectedMeasuremntDate)
        let measurement2 = AirQuality.Measurement.dummy(date: expectedMeasuremntDate)
        
        getSensorMeasurementsUseCaseSpy.fetchResultBlock = { _ in
            .success([measurement1, measurement2])
        }
        
        var sensors: [SelectedStationModel.Sensor]?
        
        sut.$sensors
            .dropFirst()
            .sink {
                sensors = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        await sut.fetchSensorsForStation()
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(getSensorsUseCaseSpy.events, [.getSensors(stationDummy.id)])
        XCTAssertEqual(getSensorMeasurementsUseCaseSpy.events.count, 2)
        XCTAssertEqual(
            Set(getSensorMeasurementsUseCaseSpy.events),
            Set([
                .getMeasurements(sensor1.id),
                .getMeasurements(sensor2.id)
            ])
        )
        XCTAssertEqual(sensors?.count, 2)
        XCTAssertEqual(
            sensors?.first(where: { $0.id == sensor1.id })?.lastMeasurementDate,
            expectedMeasuremntDateString
        )
    }
    
    func testFetchSensorsForStationWhenOneOfSensorsHasNoMeasurements() async throws {
        // Given
        let sensor1 = Sensor.dummy(id: 1)
        let sensor2 = Sensor.dummy(id: 2)
        
        getSensorsUseCaseSpy.fetchResult = .success([sensor1, sensor2])
        
        let measurement1 = AirQuality.Measurement.dummy()
        let measurement2 = AirQuality.Measurement.dummy()
        
        getSensorMeasurementsUseCaseSpy.fetchResultBlock = { sensorId in
            if sensorId == sensor1.id {
                return .success([measurement1, measurement2])
            } else {
                let afError = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 400))
                return .failure(afError)
            }
        }
        
        var sensors: [SelectedStationModel.Sensor]?
        
        sut.$sensors
            .dropFirst()
            .sink {
                sensors = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        await sut.fetchSensorsForStation()
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(getSensorsUseCaseSpy.events, [.getSensors(stationDummy.id)])
        XCTAssertEqual(getSensorMeasurementsUseCaseSpy.events.count, 2)
        XCTAssertEqual(
            Set(getSensorMeasurementsUseCaseSpy.events),
            Set([
                .getMeasurements(sensor1.id),
                .getMeasurements(sensor2.id)
            ])
        )
        XCTAssertEqual(sensors?.count, 1)
        XCTAssertEqual(sensors?.first?.id, sensor1.id)
    }
    
    func testFetchSensorsForStationWhenGettingSensorsFailure() async throws {
        // Given
        getSensorsUseCaseSpy.fetchResult = .failure(ErrorDummy())
        
        var error: Error?
        
        sut.$error
            .dropFirst()
            .sink {
                error = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        await sut.fetchSensorsForStation()
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(getSensorsUseCaseSpy.events, [.getSensors(stationDummy.id)])
        XCTAssertTrue(sut.sensors.isEmpty)
        XCTAssertNotNil(error as? ErrorDummy)
    }
    
    func testFetchSensorsForStationWhenGettingMeasurementsFailure() async throws {
        // Given
        let sensor1 = Sensor.dummy(id: 1)
        let sensor2 = Sensor.dummy(id: 2)
        
        getSensorsUseCaseSpy.fetchResult = .success([sensor1, sensor2])
        
        getSensorMeasurementsUseCaseSpy.fetchResultBlock = { _ in
            .failure(ErrorDummy())
        }
        
        var error: Error?
        
        sut.$error
            .dropFirst()
            .sink {
                error = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        await sut.fetchSensorsForStation()
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(getSensorsUseCaseSpy.events, [.getSensors(stationDummy.id)])
        XCTAssertEqual(getSensorMeasurementsUseCaseSpy.events.count, 2)
        XCTAssertEqual(
            Set(getSensorMeasurementsUseCaseSpy.events),
            Set([
                .getMeasurements(sensor1.id),
                .getMeasurements(sensor2.id)
            ])
        )
        XCTAssertTrue(sut.sensors.isEmpty)
        XCTAssertNotNil(error as? ErrorDummy)
    }
}
