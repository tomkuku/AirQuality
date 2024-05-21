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
    
    private let sensor: Sensor
    private let getArchivalMeasurementsUseCase: GetArchivalMeasurementsUseCaseProtocol
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter
    }()
    
    init(
        sensor: Sensor,
        getArchivalMeasurementsUseCase: GetArchivalMeasurementsUseCaseProtocol = GetArchivalMeasurementsUseCase()
    ) {
        self.sensor = sensor
        self.getArchivalMeasurementsUseCase = getArchivalMeasurementsUseCase
    }
    
    func fetchArchivalMeasurements() async {
        do {
            let measurements = try await getArchivalMeasurementsUseCase.getArchivalMeasurements(for: sensor.id)
            
            let rows = measurements.map {
                let formattedValue: String
                let formattedPercentageValue: String
                
                if let value = $0.value {
                    formattedValue = String(format: "%.2f", value)
                    formattedPercentageValue = "\(Int((value / sensor.param.quota) * 100))"
                } else {
                    formattedValue = "-"
                    formattedPercentageValue = "-"
                }
                
                return Model.Row(
                    percentageValue: formattedPercentageValue,
                    value: formattedValue,
                    date: dateFormatter.string(from: $0.date)
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
