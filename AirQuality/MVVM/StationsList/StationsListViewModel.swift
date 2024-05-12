//
//  StationsListViewModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 08/05/2024.
//

import Foundation

final class StationsListViewModel: ObservableObject {
    
    private let getStationsUseCase: GetStationsUseCaseProtocol
    
    @Published private(set) var stations: [Station] = []
    @Published private(set) var error: Error?
    
    init(
        getStationsUseCase: GetStationsUseCaseProtocol = GetStationsUseCase()
    ) {
        self.getStationsUseCase = getStationsUseCase
    }
    
    @MainActor
    func fetchStations() async {
        do {
            self.stations = try await getStationsUseCase.getAllStations()
        } catch {
            self.error = error
        }
    }
}
