//
//  SelectedStationViewModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import Foundation
import Alamofire

final class SelectedStationViewModel: BaseViewModel, @unchecked Sendable {
    
    typealias Model = SelectedStationModel
    
    // MARK: Properties
    
    @Published private(set) var sensors: [Model.Sensor] = []
    
    var fomattedStationAddress: String {
        station.cityName + " " + (station.street ?? "")
    }
    
    let station: Station
    
    // MARK: Private properties
    
    private let getSensorsUseCase: GetSensorsUseCaseProtocol
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter
    }()
    
    // MARK: Lifecycle
    
    init(
        station: Station,
        getSensorsUseCase: GetSensorsUseCaseProtocol = GetSensorsUseCase()
    ) {
        self.station = station
        self.getSensorsUseCase = getSensorsUseCase
    }
    
    // MARK: Methods
    
    @MainActor
    func fetchSensorsForStation() async {
        isLoading = true
        objectWillChange.send()
        
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
                    $0.lastMeasurement.percentageValue ?? 0 > $1.lastMeasurement.percentageValue ?? 0
                }
            isLoading = false
            
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
