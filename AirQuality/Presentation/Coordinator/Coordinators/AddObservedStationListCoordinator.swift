//
//  AddObservedStationListCoordinator.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 12/06/2024.
//

import Foundation
import SwiftUI

extension AddObservedStationListCoordinator {
    enum NavigationComponent: CoordinatorNavigationComponentProtocol { 
        case provinceStations(provinceName: String, stations: [Station])
    }
}

final class AddObservedStationListCoordinator: CoordinatorBase, CoordinatorProtocol {
    
    var fullScreenCover: NavigationComponent?
    
    @ViewBuilder
    @MainActor
    func startView() -> some View {
        AllStationsListProvindesView()
            .environmentObject(self)
    }
    
    @ViewBuilder
    @MainActor
    func createView(for navigationComponent: NavigationComponent) -> some View {
        switch navigationComponent {
        case .provinceStations(let provinceName, let stations):
            AllStationsListProvinceStationsView(provinceName: provinceName, stations: stations)
        }
    }
    
    func goTo(_ navigationComponent: NavigationComponent) { 
        switch navigationComponent {
        case .provinceStations:
            navigationPath.append(navigationComponent)
        }
    }
}
