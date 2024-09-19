//
//  AppCoordinator.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import SwiftUI
import Combine

extension AppCoordinator {
    enum NavigationComponent: Hashable, Identifiable {
        case stationsList
        case slectedStation(Station)
        case sensorsDetails(Sensor)
        case addNewObservedStation
        
        var id: Int {
            switch self {
            case .stationsList:             1
            case .slectedStation:           2
            case .sensorsDetails:           3
            case .addNewObservedStation:    4
            }
        }
    }
}

final class AppCoordinator: CoordinatorBase, CoordinatorProtocol {
    // MARK: Lifecycle
    
    @Published var fullScreenCover: NavigationComponent?
    
    // MARK: Methods
    
    @MainActor
    @ViewBuilder
    func startView() -> some View {
        createView(for: .stationsList)
            .environmentObject(self)
    }
    
    @MainActor
    @ViewBuilder
    func createView(for navigationComponent: NavigationComponent) -> some View {
        switch navigationComponent {
        case .stationsList:
            ObservedStationsListView()
        case .slectedStation(let station):
            let viewModel = SelectedStationViewModel(station: station)
            SelectedStationView(viewModel: viewModel)
        case .sensorsDetails(let sensor):
            let coordinator = createSensorDetailsCoordinator(for: sensor)
            CoordinatorInitialNavigationView(coordinator: coordinator)
        case .addNewObservedStation:
            let coordinator = createAddStationToObservedCoordinator()
            CoordinatorInitialView(coordinator: coordinator)
        }
    }
    
    func goTo(_ navigationComponent: NavigationComponent) {
        switch navigationComponent {
        case .stationsList, .slectedStation:
            navigationPath.append(navigationComponent)
        case .addNewObservedStation, .sensorsDetails:
            fullScreenCover = navigationComponent
        }
    }
    
    private func createAddStationToObservedCoordinator() -> AddStationToObservedCoordinator {
        if let childCoordinator = self.childCoordinator as? AddStationToObservedCoordinator {
            return childCoordinator
        }
        
        let dismissHandler: (() -> ()) = { [weak self] in
            self?.fullScreenCover = nil
        }
        
        let coordinator = AddStationToObservedCoordinator(coordinatorNavigationType: .presentation(dismissHandler: dismissHandler), alertSubject: alertSubject)
        
        childCoordinator = coordinator
        
        return coordinator
    }
    
    private func createSensorDetailsCoordinator(for sensor: Sensor) -> SensorDetailsCoordinator {
        if let childCoordinator = self.childCoordinator as? SensorDetailsCoordinator {
            return childCoordinator
        }
        
        let dismissHandler: (() -> ()) = { [weak self] in
            self?.fullScreenCover = nil
        }
        
        let coordinator = SensorDetailsCoordinator(coordinatorNavigationType: .presentation(dismissHandler: dismissHandler), sensor: sensor, alertSubject: alertSubject)
        
        childCoordinator = coordinator
        
        return coordinator
    }
}
