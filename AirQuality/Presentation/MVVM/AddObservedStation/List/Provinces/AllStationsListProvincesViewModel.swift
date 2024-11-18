//
//  AllStationsListProvincesViewModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 25/09/2024.
//

import Foundation
import Combine

@MainActor
final class AllStationsListProvincesViewModel: BaseViewModel {
    
    typealias Model = AllStationsListProvindesModel
    
    // MARK: Properties
    
    @Published private(set) var provinces: [Model.Province] = []
    
    var searchedText: String = "" {
        didSet {
            createAndSortSections(allStations)
        }
    }
    
    // MARK: Private properties
    
    @Injected(\.fetchAllStationsUseCase) private var fetchAllStationsUseCase
    @Injected(\.getObservedStationsUseCase) private var getObservedStationsUseCase
    
    private var allStations: [Station] = []
    
    // MARK: Lifecycle
    
    override init() {
        super.init()
    }
    
    // MARK: Methods
    
    func fetchStations() {
        isLoading(true, objectWillChnage: true)
        
        Task { [weak self] in
            guard let self else { return }
            
            do {
                try await checkIsInternetConnected()
                
                allStations = try await fetchAllStationsUseCase.fetch()
                
                isLoading = false
                
                createAndSortSections(allStations)
            } catch {
                Logger.error(error.localizedDescription)
                errorSubject.send(error)
            }
        }
    }
    
    // MARK: Private methods
    
    private func createAndSortSections(_ stations: [Station]) {
        var sections: [Model.Province] = stations.reduce(into: [Model.Province]()) { provinces, station in
            guard doesStationMatchToSerachedText(station) else { return }
            
            if let provinceIndex = provinces.firstIndex(where: { $0.name.lowercased() == station.province.lowercased() }) {
                provinces[provinceIndex].stations.append(station)
            } else {
                let province = Model.Province(name: station.province.capitalized, stations: [station])
                provinces.append(province)
            }
        }
        
        sortRows(in: &sections)
        
        sections.sort(by: {
            $0.name < $1.name
        })
        
        self.provinces = sections
    }
    
    private func sortRows(in provinces: inout [Model.Province]) {
        for i in 0..<provinces.count {
            provinces[i].stations.sort(by: { station1, station2 in
                if station1.cityName == station2.cityName {
                    if let lhsStreet = station1.street, let rhsSteet = station2.street {
                        lhsStreet < rhsSteet
                    } else if station1.street != nil {
                        true
                    } else {
                        false
                    }
                } else {
                    station1.cityName < station2.cityName
                }
            })
        }
    }
    
    private func doesStationMatchToSerachedText(_ station: Station) -> Bool {
        guard !searchedText.isEmpty else {
            /// If `searchedText` is empty all stations match.
            return true
        }
        
        if let stationStreet = station.street, stationStreet.contains(searchedText) {
            return true
        }
        
        return station.cityName.contains(searchedText)
    }
}
