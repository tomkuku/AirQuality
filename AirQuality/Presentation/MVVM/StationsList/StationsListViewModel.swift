//
//  StationsListViewModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 08/05/2024.
//

import Foundation

final class StationsListViewModel: ObservableObject {
    
    // MARK: Properties
    
    @Published private(set) var stations: [Station] = []
    
    // MARK: Private properties
    
    @Injected(\.appCoordinator) private var appCoordinator
    
    private let getStationsUseCase: GetStationsUseCaseProtocol
    
    init(
        getStationsUseCase: GetStationsUseCaseProtocol = GetStationsUseCase(stationsNetworkMapper: StationsNetworkMapper())
    ) {
        self.getStationsUseCase = getStationsUseCase
    }
    
    @MainActor
    func fetchStations() async {
        do {
            self.stations = try await getStationsUseCase.getStations()
        } catch {
            Logger.error(error.localizedDescription)
            appCoordinator.showAlert(.somethigWentWrong())
        }
    }
}
