//
//  AddStationToObservedListViewModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 26/05/2024.
//

import Foundation

final class AddStationToObservedListViewModel: ObservableObject {
    
    typealias Model = AddStationToObservedListModel
    
    @Published private var sortOption: Model.SortOption = .city
    
    private let getStationsUseCase: GetStationsUseCaseProtocol
    
    init(getStationsUseCase: GetStationsUseCaseProtocol) {
        self.getStationsUseCase = getStationsUseCase
    }
    
    func fetchStations() async {
        do {
            let stations = try await getStationsUseCase.getStations()
        } catch {
            Logger.error(error.localizedDescription)
        }
    }
    
    func createAndSortSections(_ stations: [Station]) {
        var sections: [Model.Sesction] = stations.reduce(into: [Model.Sesction]()) { sections, station in
            if let sectionIndex = sections.firstIndex(where: { $0.name == station.province }) {
                sections[sectionIndex].stations.append(station)
            } else {
                let section = Model.Sesction(name: station.province, stations: [station])
                sections.append(section)
            }
        }
        
        sections.sort(by: {
            $0.name > $1.name
        })
    }
    
    private func sortRows(in sections: [Model.Sesction]) {
        var sections = sections
        
        for i in 0..<sections.count {
            sections[i].stations.sort(by: {
                switch sortOption {
                case .city:
                    $0.cityName > $1.cityName
                case .street:
                    if let lhsStreet = $0.street, let rhsSteet = $1.street {
                        lhsStreet > rhsSteet
                    } else if $0.street != nil {
                        true
                    } else {
                        false
                    }
                }
            })
        }
    }
}
