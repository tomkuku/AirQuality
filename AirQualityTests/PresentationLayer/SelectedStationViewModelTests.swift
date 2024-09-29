//
//  SelectedStationViewModel.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 13/05/2024.
//

import XCTest
import Combine

@testable import AirQuality

final class SelectedStationViewModelTests: BaseTestCase, @unchecked Sendable {
    
    private var sut: SelectedStationViewModel!
    
    private var getSensorsUseCaseSpy: GetSensorsUseCaseSpy!
    private var sensorMeasurementDataFormatterSpy: SensorMeasurementDataFormatterSpy!
    
    private var stationDummy: Station!
    private var dateFormatter: DateFormatter!
    
    private var alert: AlertModel?
    private var error: Error?
    private var sensorRows: [SelectedStationModel.SensorRow]?
    
    override func setUp() async throws {
        try await super.setUp()
        
        stationDummy = .dummy()
        cancellables = Set<AnyCancellable>()
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        getSensorsUseCaseSpy = GetSensorsUseCaseSpy()
        sensorMeasurementDataFormatterSpy = SensorMeasurementDataFormatterSpy()
        
        dependenciesContainerDummy[\.getSensorsUseCase] = getSensorsUseCaseSpy
        dependenciesContainerDummy[\.sensorMeasurementDataFormatter] = sensorMeasurementDataFormatterSpy
        
        await MainActor.run {
            sut = SelectedStationViewModel(station: stationDummy)
        }
    }
    
    @MainActor
    func testFomattedStationAddress() {
        // When
        let fomattedStationAddress = sut.fomattedStationAddress
        
        // Then
        XCTAssertEqual(fomattedStationAddress, stationDummy.cityName + ", " + stationDummy.street!)
    }
    
    @MainActor
    func testFomattedStationAddressWhenStationsAddressHasNoStreet() {
        // Given
        stationDummy = .dummy(street: nil)
        
        sut = SelectedStationViewModel(station: stationDummy)
        
        // When
        let fomattedStationAddress = sut.fomattedStationAddress
        
        // Then
        XCTAssertEqual(fomattedStationAddress, stationDummy.cityName)
    }
    
    @MainActor
    func testFetchSensorsForStationWhenSuccess() async throws {
        // Given
        let sensor1 = Sensor.dummy(id: 1, param: .pm10, measurements: [.dummy(date: "2024-06-25 15:00", value: 45)])
        let sensor2 = Sensor.dummy(id: 2, param: .pm25, measurements: [.dummy(date: "2024-06-25 15:00", value: 34)])
        let sensor3 = Sensor.dummy(id: 3, param: .c6h6, measurements: [
            .dummy(date: "2024-06-25 14:00", value: nil),
            .dummy(date: "2024-06-25 14:00", value: 4)
        ])
        
        getSensorsUseCaseSpy.getSensorsResultClosure = {
            .success([sensor3, sensor1, sensor2])
        }
        
        let expectedFirstSensorRow = SelectedStationModel.SensorRow(
            id: sensor1.id,
            param: sensor1.param,
            lastMeasurementAqi: .moderate,
            lastMeasurementPercentageValue: 0.9,
            lastMeasurementFormattedDate: "Jun 25, 2024 at 15:00",
            lastMeasurementFormattedValue: "45 µg/m³",
            lastMeasurementFormattedPercentageValue: "90%"
        )
        
        let expectedSecondSensorRow = SelectedStationModel.SensorRow(
            id: sensor2.id,
            param: sensor2.param,
            lastMeasurementAqi: .moderate,
            lastMeasurementPercentageValue: 1.36,
            lastMeasurementFormattedDate: "Jun 25, 2024 at 15:00",
            lastMeasurementFormattedValue: "34 µg/m³",
            lastMeasurementFormattedPercentageValue: "136%"
        )
        
        let expectedThirdSensorRow = SelectedStationModel.SensorRow(
            id: sensor3.id,
            param: sensor3.param,
            lastMeasurementAqi: .good,
            lastMeasurementPercentageValue: 0.8,
            lastMeasurementFormattedDate: "Jun 25, 2024 at 14:00",
            lastMeasurementFormattedValue: "4 µg/m³",
            lastMeasurementFormattedPercentageValue: "80%"
        )
        
        sut.$sensors
            .dropFirst()
            .sink {
                self.sensorRows = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        await sut.fetchSensorsForStation()
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(getSensorsUseCaseSpy.events, [.getSensors(stationDummy.id)])
        XCTAssertEqual(sensorRows, [expectedSecondSensorRow, expectedFirstSensorRow, expectedThirdSensorRow])
        XCTAssertEqual(sensorMeasurementDataFormatterSpy.events, [
            .format("2024-06-25 14:00"),
            .format("2024-06-25 15:00"),
            .format("2024-06-25 15:00")
        ])
        
        XCTAssertEqual(sut.getSensor(for: 1), sensor1)
        XCTAssertEqual(sut.getSensor(for: 2), sensor2)
        XCTAssertEqual(sut.getSensor(for: 3), sensor3)
        XCTAssertFalse(sut.isLoading)
    }
    
    @MainActor
    func testFetchSensorsForStationWhenFailure() async throws {
        // Given
        getSensorsUseCaseSpy.getSensorsResultClosure = {
            .failure(ErrorDummy())
        }
        
        sut.errorSubject
            .sink {
                self.error = $0
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        await sut.fetchSensorsForStation()
        
        // Then
        await fulfillment(of: [self.expectation], timeout: 2.0)
        
        XCTAssertNotNil(error as? ErrorDummy)
        XCTAssertEqual(getSensorsUseCaseSpy.events, [.getSensors(stationDummy.id)])
    }
    
    @MainActor
    func testRefresh() {
        // Given
        getSensorsUseCaseSpy.getSensorsResultClosure = {
            .success([])
        }
        
        sut.$sensors
            .dropFirst()
            .sink { _ in
                self.expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.refresh()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(getSensorsUseCaseSpy.events, [.getSensors(stationDummy.id)])
        XCTAssertFalse(sut.isLoading)
    }
}

extension SelectedStationModel.SensorRow: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id &&
        lhs.lastMeasurementAqi == rhs.lastMeasurementAqi &&
        lhs.param == rhs.param &&
        lhs.lastMeasurementFormattedDate == rhs.lastMeasurementFormattedDate &&
        lhs.lastMeasurementFormattedPercentageValue == rhs.lastMeasurementFormattedPercentageValue &&
        lhs.lastMeasurementFormattedValue == rhs.lastMeasurementFormattedValue &&
        lhs.lastMeasurementPercentageValue == rhs.lastMeasurementPercentageValue
    }
}
