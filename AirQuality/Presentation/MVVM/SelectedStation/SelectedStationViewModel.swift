//
//  SelectedStationViewModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import Foundation
import Alamofire

final class SelectedStationViewModel: ObservableObject {
    
    // MARK: Properties
    
    @Published private(set) var sensors: [Sensor] = []
    @Published private(set) var error: Error?
    
    var fomattedStationAddress: String {
        station.cityName + " " + (station.street ?? "")
    }
    
    let station: Station
    
    // MARK: Private properties
    
    private let getSensorsUseCase: GetSensorsUseCaseProtocol
    
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
        do {
            self.sensors = try await getSensorsUseCase.getSensors(for: station.id)
        } catch {
            Logger.error(error.localizedDescription)
            self.error = error
        }
    }
}
