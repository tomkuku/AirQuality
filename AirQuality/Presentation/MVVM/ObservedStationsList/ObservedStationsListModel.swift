//
//  StationsListViewModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 08/05/2024.
//

import Foundation
import CoreLocation

final class StationsListViewModel: BaseViewModel {
    
    // MARK: Properties
    
    @Published private(set) var stations: [Station] = []
    
    // MARK: Private properties
    
    @Injected(\.getObservedStationsUseCase) private var getObservedStationsUseCase
    @Injected(\.deleteObservedStationUseCase) private var deleteObservedStationUseCase
    @Injected(\.locationRespository) private var locationRespository
    
    // MARK: Lifecycle
    
    override init() {
        super.init()
        
        observeStations()
    }
    
    func deletedObservedStation(_ station: Station) {
        Task { [weak self] in
            guard let self else { return }
            
            do {
                try await self.deleteObservedStationUseCase.delete(station: station)
                self.toastSubject.send(Toast(body: "Stacja została usunięta z listy obserwowanych"))
            } catch {
                Logger.error("Observing station faild with error: \(error.localizedDescription)")
                alertSubject.send(.somethigWentWrong())
            }
        }
    }
    
    private func observeStations() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            
            do {
                for try await stations in getObservedStationsUseCase.createNewStream() {
                    self.stations = stations
                }
            } catch {
                Logger.error(error.localizedDescription)
                alertSubject.send(.somethigWentWrong())
            }
        }
    }
}
