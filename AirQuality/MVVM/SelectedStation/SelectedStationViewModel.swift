//
//  SelectedStationViewModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import Foundation
import Alamofire

final class SelectedStationViewModel: ObservableObject {
    
    let station: Station
    
    @Published private(set) var sensors: [SelectedStationModel.Sensor] = []
    @Published private(set) var error: Error?
    
    var fomattedStationAddress: String {
        station.cityName + " " + (station.street ?? "")
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }()
    
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
    
    func fetchSensorsForStation() async {
        do {
            var sensors = try await getSensorsUseCase.getSensors(for: station.id)
            
            sensors = try await withThrowingTaskGroup(of: Sensor?.self) { group in
                sensors.forEach { sensor in
                    group.addTask { [weak self] in
                        do {
                            return try await self?.fetchMeasurementsForSensor(sensor: sensor)
                        } catch {
                            guard
                                let afError = error.asAFError,
                                case .responseValidationFailed(let reason) = afError,
                                case .unacceptableStatusCode(let code) = reason,
                                code == 400
                            else {
                                throw error
                            }
                            
                            return nil
                        }
                    }
                }
                
                var sensorsWithMeasurements = [Sensor]()
                
                for try await value in group {
                    guard let value else { continue }
                    sensorsWithMeasurements.append(value)
                }
                
                return sensorsWithMeasurements
            }
            
            formatSensorsMeasuremnts(sensors: sensors)
        } catch {
            Logger.error(error.localizedDescription)
            self.error = error
        }
    }
    
    private func formatSensorsMeasuremnts(sensors: [Sensor]) {
        let formattedSensors = sensors.map { sensor in
            var formattedMeasurementDate: String?
            var formattedMeasurementValue: String?
            
            if sensor.measurements.isEmpty {
                formattedMeasurementValue = "No measuremnts"
            } else {
                for measurement in sensor.measurements {
                    let formattedDate = dateFormatter.string(from: measurement.date)
                    let formattedValue = String(format: "%.2f", measurement.value)
                    
                    formattedMeasurementDate = formattedDate
                    formattedMeasurementValue = formattedValue
                }
            }
            
            return SelectedStationModel.Sensor(
                id: sensor.id,
                name: sensor.name,
                formula: sensor.formula,
                lastMeasurementValue: formattedMeasurementValue ?? "",
                lastMeasurementDate: formattedMeasurementDate ?? ""
            )
        }
        
        self.sensors = formattedSensors
    }
    
    private func fetchMeasurementsForSensor(sensor: Sensor) async throws -> Sensor {
        var sensor = sensor
        let measurements = try await getSensorMeasurementsUseCase.getMeasurements(for: sensor.id)
        
        sensor.measurements = measurements
        
        return sensor
    }
}
