//
//  AppCoordinator.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import SwiftUI
import Combine
import Network

extension AppCoordinator {
    enum NavigationComponent: Hashable, Identifiable {
        case stationsList
        case selectedStation(Station)
        case sensorsDetails(Sensor)
        case addNewObservedStation
        case archivalMeasurements(Sensor)
        case archivalMeasurementsOptions(SensorArchivalMeasurementsListOptions, callback: (SensorArchivalMeasurementsListOptions) -> ())
        
        var id: Int {
            switch self {
            case .stationsList:                 1
            case .selectedStation:              2
            case .sensorsDetails:               3
            case .addNewObservedStation:        4
            case .archivalMeasurements:         5
            case .archivalMeasurementsOptions:  6
            }
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: AppCoordinator.NavigationComponent, rhs: AppCoordinator.NavigationComponent) -> Bool {
            lhs.id == rhs.id
        }
    }
}

@MainActor
final class AppCoordinator: CoordinatorBase, CoordinatorProtocol {
    
    // MARK: Properties
    
    @Published var fullScreenCover: NavigationComponent?
    
    // MARK: Private properties
    
    @Injected(\.networkConnectionMonitorUseCase) private var networkConnectionMonitorUseCase
    
    // MARK: Lifecycle
    
    override init(
        coordinatorNavigationType: CoordinatorNavigationType,
        alertSubject: PassthroughSubject<AlertModel, Never>,
        toastSubject: PassthroughSubject<ToastModel, Never>
    ) {
        super.init(
            coordinatorNavigationType: coordinatorNavigationType,
            alertSubject: alertSubject,
            toastSubject: toastSubject
        )
    }
    
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
        case .selectedStation(let station):
            let viewModel = SelectedStationViewModel(station: station)
            SelectedStationView(viewModel: viewModel)
        case .sensorsDetails(let sensor):
            let coordinator = createSensorDetailsCoordinator(for: sensor)
            CoordinatorInitialNavigationView(coordinator: coordinator)
        case .addNewObservedStation:
            let coordinator = createAddStationToObservedCoordinator()
            CoordinatorInitialView(coordinator: coordinator)
        case .archivalMeasurements(let sensor):
            let useCase = FetchArchivalMeasurementsUseCase(sensor: sensor)
            let viewModel = SensorArchivalMeasurementsListViewModel(sensor: sensor, useCase: useCase)
            SensorArchivalMeasurementsListView(viewModel: viewModel)
        case .archivalMeasurementsOptions(let options, let callback):
            let viewModel = SensorArchivalMeasurementsFiltersViewModel(options: options, callback: callback)
            SensorArchivalMeasurementsFiltersView(viewModel: viewModel)
        }
    }
    
    func goTo(_ navigationComponent: NavigationComponent) {
        switch navigationComponent {
        case .stationsList, .selectedStation, .archivalMeasurements, .archivalMeasurementsOptions:
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
        
        let coordinator = AddStationToObservedCoordinator(
            childOf: self,
            navigationType: .presentation(dismissHandler: dismissHandler)
        )
        
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
        
        let coordinator = SensorDetailsCoordinator(
            childOf: self,
            navigationType: .presentation(dismissHandler: dismissHandler),
            sensor: sensor
        )
        
        childCoordinator = coordinator
        
        return coordinator
    }
    
    nonisolated func monitorInternetConnection() {
        Task { @MainActor [weak self] in
            await self?.networkConnectionMonitorUseCase.startMonitor { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    self?.showToast(.noInternetConnection())
                }
            }
        }
    }
}
