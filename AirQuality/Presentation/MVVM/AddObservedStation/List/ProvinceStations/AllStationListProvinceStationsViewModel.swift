//
//  AllStationListProvinceStationsViewModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 25/09/2024.
//

import Foundation

final class AllStationListProvinceStationsViewModel: BaseViewModel {
    
    typealias Model = AllStationsListProvindesModel
    
    // MARK: Properties
    
    @Published private(set) var stations: [(station: Station, isObserved: Bool)] = []
    
    // MARK: Private properties
    
    @Injected(\.getObservedStationsUseCase) private var getObservedStationsUseCase
    
    private let allStationsInProvicne: [Station]
    private var task: Task<Void, Never>?
    
    // MARK: Lifecycle
    
    init(allStationsInProvicne: [Station]) {
        self.allStationsInProvicne = allStationsInProvicne
        
        super.init()
        
        streamObservedStations()
    }
    
    deinit {
        task = nil
    }
    
    // MARK: Methods
    
    func fetchStations() {
        Task { [weak self] in
            do {
                let observedStations = try await self?.getObservedStationsUseCase.fetchedStations()
                
                await MainActor.run { [weak self] in
                    self?.prepareStations(observedStations: observedStations ?? [])
                }
            } catch {
                Logger.error(error.localizedDescription)
                self?.alertSubject.send(.somethigWentWrong())
            }
        }
    }
    
    func streamObservedStations() {
        task = Task {
            do {
                for try await observedStations in getObservedStationsUseCase.createNewStream() {
                    await MainActor.run {
                        prepareStations(observedStations: observedStations)
                    }
                }
            } catch {
                Logger.error(error.localizedDescription)
                alertSubject.send(.somethigWentWrong())
            }
        }
    }
    
    // MARK: Private methods
    
    private func prepareStations(observedStations: [Station]) {
        self.stations = allStationsInProvicne.map { station in
            let isStationObserved = observedStations.contains(where: { $0.id == station.id })
            return (station, isStationObserved)
        }
    }
}
