//
//  StationsListViewModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 08/05/2024.
//

import Foundation

final class StationsListViewModel: BaseViewModel {
    
    // MARK: Properties
    
    @Published private(set) var stations: [Station] = []
    
    // MARK: Private properties
    
    private let getStationsUseCase: GetStationsUseCaseProtocol
    
    init(
        getStationsUseCase: GetStationsUseCaseProtocol = GetStationsUseCase(stationsNetworkMapper: StationsNetworkMapper())
    ) {
        self.getStationsUseCase = getStationsUseCase
    }
    
    @MainActor
    func fetchStations() { 
        Task {
            do {
                self.stations = try await getStationsUseCase.getStations()
            } catch {
                Logger.error(error.localizedDescription)
                alertSubject.send(.somethigWentWrong())
            }
        }
    }
}
