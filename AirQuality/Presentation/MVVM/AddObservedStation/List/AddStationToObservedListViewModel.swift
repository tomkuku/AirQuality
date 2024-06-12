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
    private var searchedText: String = ""
    
    // MARK: Lifecycle
    
    override init() {
        super.init()
        
        receiveObservedStationsStream()
    }
    
    // MARK: Methods
    
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
        
        print("LL start")
        
        Task { @MainActor [weak self] in
            print("LL start 2", self)
            guard let self else { return }
            
            do {
                print("LL start 3", getStationsUseCase)
                let fetchedStations = try await getStationsUseCase.getStations()
                print("LL fetched stations", fetchedStations)
                let observedStations = try await getObservedStationsUseCase.fetchedStations()
                print("LL fetched observed stations", observedStations)
                
                print("LL fetched")
                
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
    
    func searchedTextDidChange(_ text: String) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            
            self.searchedText = text
            
            do {
                let observedStations = try await self.getObservedStationsUseCase.fetchedStations()
                
                self.createAndSortSections(fetchedStations, observedStations: observedStations)
            } catch {
                Logger.error("Observing station faild with error: \(error.localizedDescription)")
                self.alertSubject.send(.somethigWentWrong())
            }
        }
    }
    
    // MARK: Private methods
    
    private func createAndSortSections(_ stations: [Station], observedStations: [Station]) {
        var sections: [Model.Section] = stations.reduce(into: [Model.Section]()) { sections, station in
            if !searchedText.isEmpty && !isStationMatchToSerachedText(station) {
                return
            }
            
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
        
        print("LL done", sections.count, stations)
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
    
    private func isStationMatchToSerachedText(_ station: Station) -> Bool {
        if let stationStreet = station.street, stationStreet.contains(searchedText) {
            return true
        }
        
        return station.cityName.contains(searchedText)
    }
}
