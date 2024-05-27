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
    
    @Published private(set) var stations: [Station] = []
    @Published private(set) var sections: [Model.Section] = []
    
    var errorPublisher: AnyPublisher<Error, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    // MARK: Private properties
    
    private let getStationsUseCase: GetStationsUseCaseProtocol
    private let errorSubject = PassthroughSubject<Error, Never>()
    
    init(getStationsUseCase: GetStationsUseCaseProtocol = GetStationsUseCase()) {
        self.getStationsUseCase = getStationsUseCase
    }
    
    @HandlerActor
    func fetchStations() async {
        do {
            let stations = try await getStationsUseCase.getStations()
            let sections = createAndSortSections(stations)
            
            await MainActor.run {
                self.sections = sections
            }
        } catch {
            Logger.error(error.localizedDescription)
            errorSubject.send(error)
        }
    }
    
    func createAndSortSections(_ stations: [Station]) -> [Model.Section] {
        var sections: [Model.Section] = stations.reduce(into: [Model.Section]()) { sections, station in
            if let sectionIndex = sections.firstIndex(where: { $0.name == station.province }) {
                sections[sectionIndex].stations.append(station)
            } else {
                let section = Model.Section(name: station.province, stations: [station])
                sections.append(section)
            }
        }
        
        sortRows(in: &sections)
        
        sections.sort(by: {
            $0.name > $1.name
        })
        
        return sections
    }
    
    private func sortRows(in sections: inout [Model.Section]) {
        for i in 0..<sections.count {
            sections[i].stations.sort(by: {
                if $0.cityName == $1.cityName {
                    if let lhsStreet = $0.street, let rhsSteet = $1.street {
                        lhsStreet > rhsSteet
                    } else if $0.street != nil {
                        true
                    } else {
                        false
                    }
                } else {
                    $0.cityName > $1.cityName
                }
            })
        }
    }
}
