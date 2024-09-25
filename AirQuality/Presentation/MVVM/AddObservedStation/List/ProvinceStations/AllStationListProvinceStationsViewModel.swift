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
    
    @Injected(\.observedStationsFetchResultsRepository) private var observedStationsFetchResultsRepository
    
    private let allStationsInProvicne: [Station]
    private var task: Task<Void, Never>?
    
    // MARK: Lifecycle
    
    init(allStationsInProvicne: [Station]) {
        self.allStationsInProvicne = allStationsInProvicne
        
        super.init()
        
        fetchStations()
    }
    
    deinit {
        task = nil
    }
    
    // MARK: Methods
    
    func fetchStations() {
        task = Task {
            do {
                for try await observedStations in observedStationsFetchResultsRepository.ceateNewStrem() {
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
