//
//  AllStationStationViewModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 03/07/2024.
//

import Foundation

@MainActor
final class AllStationStationViewModel: BaseViewModel {
    
    // MARK: Private properties
    
    @Injected(\.addObservedStationUseCase) private var addObservedStationUseCase
    @Injected(\.deleteObservedStationUseCase) private var deleteObservedStationUseCase
    
    private let station: Station
    
    init(station: Station) {
        self.station = station
        super.init()
    }
    
    // MARK: Methods
    
    func addObservedStation(_ station: Station) {
        Task { [weak self] in
            do {
                try await self?.addObservedStationUseCase.add(station: station)
                self?.toastSubject.send(.observedStationWasAdded())
            } catch {
                Logger.error("Observing station faild with error: \(error.localizedDescription)")
                self?.alertSubject.send(.somethigWentWrong())
            }
        }
    }
    
    func deletedObservedStation(_ station: Station) {
        Task { [weak self] in
            do {
                try await self?.deleteObservedStationUseCase.delete(station: station)
                self?.toastSubject.send(.observedStationWasDeleted())
            } catch {
                Logger.error("Observing station faild with error: \(error.localizedDescription)")
                self?.alertSubject.send(.somethigWentWrong())
            }
        }
    }
}
