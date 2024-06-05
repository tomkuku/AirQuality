//
//  SensorArchivalMeasurementsListViewModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 21/05/2024.
//

import Foundation

final class SensorArchivalMeasurementsListViewModel: ObservableObject, @unchecked Sendable {
    
    typealias Model = SensorArchivalMeasurementsListModel
    
    @Published private(set) var rows: [Model.Row] = []
    
    private(set) var idLoading = true
    
    let sensor: Sensor
    private let getArchivalMeasurementsUseCase: GetArchivalMeasurementsUseCaseProtocol
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter
    }()
    
    init(
        sensor: Sensor,
        getArchivalMeasurementsUseCase: GetArchivalMeasurementsUseCaseProtocol = GetArchivalMeasurementsUseCase(measurementsNetworkMapper: MeasurementsNetworkMapper())
    ) {
        self.sensor = sensor
        self.getArchivalMeasurementsUseCase = getArchivalMeasurementsUseCase
    }
    
    func fetchArchivalMeasurements() async {
        do {
            let measurements = try await getArchivalMeasurementsUseCase.getArchivalMeasurements(for: sensor.id)
            
            let rows = measurements.map {
                let percentageValue: Double
                let formattedValue: String
                let formattedPercentageValue: String
                let formattedDate = dateFormatter.string(from: $0.date)
                
                if let value = $0.value {
                    percentageValue = Double(((value / sensor.param.quota) * 100).rounded(.down))
                    formattedValue = String(format: "%.2f", value)
                    formattedPercentageValue = "\(percentageValue)"
                } else {
                    percentageValue = 0
                    formattedValue = "-"
                    formattedPercentageValue = "-"
                }
                
                return Model.Row(
                    formattedPercentageValue: formattedPercentageValue,
                    formattedValue: formattedValue,
                    formattedDate: formattedDate,
                    value: $0.value ?? 0,
                    percentageValue: percentageValue,
                    date: $0.date
                )
            }
            
            await MainActor.run { [weak self] in
                self?.idLoading = false
                self?.rows = rows
            }
        } catch {
            print(error)
        }
    }
}
