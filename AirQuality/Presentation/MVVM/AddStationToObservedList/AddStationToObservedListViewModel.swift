//
//  AddStationToObservedListViewModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 26/05/2024.
//

import Foundation
import Combine

final class AddStationToObservedListViewModel: ObservableObject, @unchecked Sendable {
    
    typealias Model = AddStationToObservedListModel
    
    // MARK: Properties
    
    @Published private(set) var sections: [Model.Section] = []
    
    @MainActor
    private(set) var isLoading = false
    
    @MainActor
    var errorPublisher: AnyPublisher<Error, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    // MARK: Private properties
    
    private let getStationsUseCase: GetStationsUseCaseProtocol
    private let observeStationUseCase: ObserveStationUseCaseProtocol
    private let deleteStationFromObservedListUseCase: DeleteStationFromObservedListUseCaseProtocol
    private let getObservedStationsUseCase: GetObservedStationsUseCaseProtocol
    private let errorSubject = PassthroughSubject<Error, Never>()
    
    @MainActor
    private var fetchedStations: [Station] = []
    
    init(
        getStationsUseCase: GetStationsUseCaseProtocol = GetStationsUseCase(),
        observeStationUseCase: ObserveStationUseCaseProtocol = ObserveStationUseCase(),
        deleteStationFromObservedListUseCase: DeleteStationFromObservedListUseCaseProtocol = DeleteStationFromObservedListUseCase(),
        getObservedStationsUseCase: GetObservedStationsUseCaseProtocol = GetObservedStationsUseCase()
    ) {
        self.getStationsUseCase = getStationsUseCase
        self.observeStationUseCase = observeStationUseCase
        self.deleteStationFromObservedListUseCase = deleteStationFromObservedListUseCase
        self.getObservedStationsUseCase = getObservedStationsUseCase
        
        receiveObservedStationsStream()
    }
    
    func receiveObservedStationsStream() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            
            do {
                for try await observedSations in getObservedStationsUseCase.createNewStream() {
                    self.createAndSortSections(fetchedStations, observedStations: observedSations)
                }
            } catch {
                Logger.error(error.localizedDescription)
                errorSubject.send(error)
            }
        }
    }
    
    func fetchStations() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            
            do {
                let fetchedStations = try await getStationsUseCase.getStations()
                let observedStations = try await getObservedStationsUseCase.fetchedStations()
                
                createAndSortSections(fetchedStations, observedStations: observedStations)
                self.fetchedStations = fetchedStations
            } catch {
                Logger.error(error.localizedDescription)
                errorSubject.send(error)
            }
        }
    }
    
    func stationDidSelect(_ station: Station) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            
            do {
                let observedStations = try await getObservedStationsUseCase.fetchedStations()
                
                if observedStations.contains(station) {
                    try await deleteStationFromObservedListUseCase.delete(station: station)
                } else {
                    try await observeStationUseCase.observe(station: station)
                }
            } catch {
                Logger.error("Observing station faild with error: \(error.localizedDescription)")
                errorSubject.send(error)
            }
        }
    }
    
    @MainActor
    private func createAndSortSections(_ stations: [Station], observedStations: [Station]) {
        var sections: [Model.Section] = stations.reduce(into: [Model.Section]()) { sections, station in
            let row = Model.Row(station: station, isStationObserved: observedStations.contains(station))
            
            if let sectionIndex = sections.firstIndex(where: { $0.name.lowercased() == station.province.lowercased() }) {
                sections[sectionIndex].rows.append(row)
            } else {
                let section = Model.Section(name: station.province.capitalized, rows: [row])
                sections.append(section)
            }
        }
        
        sortRows(in: &sections)
        
        sections.sort(by: {
            $0.name > $1.name
        })
        
        self.sections = sections
    }
    
    private func sortRows(in sections: inout [Model.Section]) {
        for i in 0..<sections.count {
            sections[i].rows.sort(by: {
                if $0.station.cityName == $1.station.cityName {
                    if let lhsStreet = $0.station.street, let rhsSteet = $1.station.street {
                        lhsStreet > rhsSteet
                    } else if $0.station.street != nil {
                        true
                    } else {
                        false
                    }
                } else {
                    $0.station.cityName > $1.station.cityName
                }
            })
        }
    }
}
