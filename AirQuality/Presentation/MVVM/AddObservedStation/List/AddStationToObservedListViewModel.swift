//
//  AddStationToObservedListViewModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 26/05/2024.
//

import Foundation
import Combine

final class AddStationToObservedListViewModel: BaseViewModel, @unchecked Sendable {
    
    typealias Model = AddStationToObservedListModel
    
    // MARK: Properties
    
    @Published private(set) var sections: [Model.Section] = []
    
    // MARK: Private properties
    
    @Injected(\.addObservedStationUseCase) private var addObservedStationUseCase
    @Injected(\.deleteObservedStationUseCase) private var deleteObservedStationUseCase
    @Injected(\.getObservedStationsUseCase) private var getObservedStationsUseCase
    @Injected(\.getStationsUseCase) private var getStationsUseCase
    
    @MainActor
    private var fetchedStations: [Station] = []
    
    override init() {
        super.init()
        
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
                alertSubject.send(.somethigWentWrong())
            }
        }
    }
    
    func fetchStations() {
        isLoading(true, objectWillChnage: true)
        
        Task { @MainActor [weak self] in
            guard let self else { return }
            
            do {
                let fetchedStations = try await getStationsUseCase.getStations()
                let observedStations = try await getObservedStationsUseCase.fetchedStations()
                
                isLoading(false, objectWillChnage: false)
                
                createAndSortSections(fetchedStations, observedStations: observedStations)
                self.fetchedStations = fetchedStations
            } catch {
                Logger.error(error.localizedDescription)
                alertSubject.send(.somethigWentWrong())
            }
        }
    }
    
    func stationDidSelect(_ station: Station) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            
            do {
                let observedStations = try await getObservedStationsUseCase.fetchedStations()
                
                if observedStations.contains(station) {
                    try await deleteObservedStationUseCase.delete(station: station)
                } else {
                    try await addObservedStationUseCase.add(station: station)
                }
            } catch {
                Logger.error("Observing station faild with error: \(error.localizedDescription)")
                alertSubject.send(.somethigWentWrong())
            }
        }
    }
    
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
