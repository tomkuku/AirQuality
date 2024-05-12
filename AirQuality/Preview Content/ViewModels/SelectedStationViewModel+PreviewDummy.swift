//
//  SelectedStationViewModel+PreviewDummy.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 12/05/2024.
//

import Foundation

extension SelectedStationViewModel {
    private struct GetSensorsUseCase: GetSensorsUseCaseProtocol {
        func getSensors(for stationId: Int) async throws -> [Sensor] {
            [
                Sensor.previewDummy(),
                Sensor.previewDummy(id: 13, name: "Particulate Matter PM10", formula: "PM10", code: "PM10")
            ]
        }
    }
    
    nonisolated(unsafe) static let previewDummy = SelectedStationViewModel(
        station: .previewDummy(),
        getSensorsUseCase: GetSensorsUseCase()
    )
}
