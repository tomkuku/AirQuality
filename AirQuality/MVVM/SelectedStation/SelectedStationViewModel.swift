//
//  SelectedStationViewModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import Foundation

final class SelectedStationViewModel: ObservableObject {
    
    let station: Station
    
    @Published private(set) var sensors: [Sensor] = []
    @Published private(set) var error: Error?
    
    var fomattedStationAddress: String {
        station.cityName + (station.street ?? "")
    }
    
    private let getSensorsUseCase: GetSensorsUseCaseProtocol
    private let getSensorMeasurementsUseCase: GetSensorMeasurementsUseCaseProtocol
    
    init(
        station: Station,
        getSensorsUseCase: GetSensorsUseCaseProtocol = GetSensorsUseCase(),
        getSensorMeasurementsUseCase: GetSensorMeasurementsUseCaseProtocol = GetSensorMeasurementsUseCase()
    ) {
        self.station = station
        self.getSensorsUseCase = getSensorsUseCase
        self.getSensorMeasurementsUseCase = getSensorMeasurementsUseCase
    }
    
    @MainActor
    func fetchSensorsForStation() async {
        do {
            let sensors = try await getSensorsUseCase.getSensors(for: station.id)
            
            self.sensors = try await withThrowingTaskGroup(of: Sensor?.self) { group in
                sensors.forEach { sensor in
                    group.addTask { [weak self] in
                        try await self?.fetchMeasurementsForSensor(sensor: sensor)
                    }
                }
                
                var sensorsWithMeasurements = [Sensor]()
                
                for try await value in group {
                    guard let value else { continue }
                    sensorsWithMeasurements.append(value)
                }
                
                return sensorsWithMeasurements
            }
        } catch {
            Logger.error(error.localizedDescription)
            self.error = error
        }
    }
    
    private func fetchMeasurementsForSensor(sensor: Sensor) async throws -> Sensor {
        var sensor = sensor
        let measurements = try await getSensorMeasurementsUseCase.getMeasurements(for: sensor.id)
        
        sensor.measurements = measurements
        
        return sensor
    }
}
