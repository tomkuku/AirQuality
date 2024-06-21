//
//  SelectedStationViewModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import Foundation

final class SelectedStationViewModel: BaseViewModel, @unchecked Sendable {
    
    typealias Model = SelectedStationModel
    
    // MARK: Properties
    
    @Published private(set) var sensors: [Model.Sensor] = []
    
    var fomattedStationAddress: String {
        station.cityName + ", " + (station.street ?? "")
    }
    
    let station: Station
    
    // MARK: Private properties
    
    @Injected(\.getSensorsUseCase) private var getSensorsUseCase
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter
    }()
    
    // MARK: Lifecycle
    
    init(station: Station) {
        self.station = station
        super.init()
    }
    
    // MARK: Methods
    
    @MainActor
    func fetchSensorsForStation() async {
        isLoading(true, objectWillChnage: true)
        
        do {
            let sensors = try await getSensorsUseCase.getSensors(for: station.id)
                .map {
                    Model.Sensor(
                        id: $0.id,
                        domainModel: $0,
                        lastMeasurement: formatLastMeasurement(for: $0)
                    )
                }
                .sorted {
                    let currentSensorLastMeasurementPercentageValue = $0.lastMeasurement.percentageValue
                    let nextSensorLastMeasurementPercentageValue = $1.lastMeasurement.percentageValue
                    let currentSensorLastMeasurementAqi = $0.domainModel.param.getAqi(for: $0.lastMeasurement.measurement?.value)
                    let nextSensorLastMeasurementAqi = $1.domainModel.param.getAqi(for: $1.lastMeasurement.measurement?.value)
                    
                    return if currentSensorLastMeasurementAqi == nextSensorLastMeasurementAqi {
                        currentSensorLastMeasurementPercentageValue ?? 0 > nextSensorLastMeasurementPercentageValue ?? 0
                    } else {
                        currentSensorLastMeasurementAqi > nextSensorLastMeasurementAqi
                    }
                }
            
            isLoading(false, objectWillChnage: false)
            
            self.sensors = sensors
        } catch {
            Logger.error(error.localizedDescription)
            alertSubject.send(.somethigWentWrong())
        }
    }
    
    private func formatLastMeasurement(for sensor: Sensor) -> Model.LastMeasurement {
        var measurement: Measurement?
        var formattedDate = ""
        var formattedValue = "-"
        var percentageValue: Int?
        var formattedPercentageValue = "-"
        
        if let lastMeasuremnt = sensor.measurements.first {
            measurement = lastMeasuremnt
            formattedDate = dateFormatter.string(from: lastMeasuremnt.date)
            
            if let value = lastMeasuremnt.value {
                formattedValue = String(format: "%.2f", value)
                percentageValue = Int((value / sensor.param.quota) * 100)
                
                if let percentageValue {
                    formattedPercentageValue = "\(percentageValue)"
                }
            }
        }
        
        return Model.LastMeasurement(
            measurement: measurement,
            percentageValue: percentageValue,
            formattedDate: formattedDate,
            formattedValue: formattedValue,
            formattedPercentageValue: formattedPercentageValue
        )
    }
}
