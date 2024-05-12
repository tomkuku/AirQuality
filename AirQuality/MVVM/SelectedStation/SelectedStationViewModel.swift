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
    
    init(
        station: Station,
        getSensorsUseCase: GetSensorsUseCaseProtocol = GetSensorsUseCase()
    ) {
        self.station = station
        self.getSensorsUseCase = getSensorsUseCase
    }
    
    @MainActor
    func fetchSensorsForStation() async {
        do {
            self.sensors = try await getSensorsUseCase.getSensors(for: station.id)
        } catch {
            self.error = error
        }
    }
}
