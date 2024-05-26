//
//  AppCoordinator.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import SwiftUI
import Combine

protocol HasAppCoordinator {
    var appCoordinator: AppCoordinatorProtocol { get }
}

protocol AppCoordinatorProtocol {
    func goToStationsList()
    func gotSelectedStation(_ station: Station)
    func goToSensorDetailsView(for sensor: Sensor)
    func showAlert(_ alert: AlertModel)
    func dismiss()
}

enum AppFlow: Hashable, Identifiable {
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

protocol CoordinatorProtocol: ObservableObject {
    associatedtype NavigationComponentType: Identifiable
    associatedtype StartViewType: View
    associatedtype CreateViewType: View
    
    @ViewBuilder
    @MainActor
    func start() -> StartViewType
    
    @ViewBuilder
    @MainActor
    func createView(for navigationComponent: NavigationComponentType) -> CreateViewType
    
    func showAlert(_ alert: AlertModel)
}

final class AppCoordinator: ObservableObject, AppCoordinatorProtocol {
    
    // MARK: Properties
    
    @Published var navigationPath: NavigationPath
    @Published var fullScreenCover: AppFlow?
    
    var alertPublisher: AnyPublisher<AlertModel, Never> {
        alertSubject.eraseToAnyPublisher()
    }
    
    var dismissPublisher: AnyPublisher<Void, Never> {
        dismissSubject.eraseToAnyPublisher()
    }
    
    // MARK: Private properties
    
    private let alertSubject = PassthroughSubject<AlertModel, Never>()
    private let dismissSubject = PassthroughSubject<Void, Never>()
    
    private var childCoordinator: (any ObservableObject)?
    
    // MARK: Lifecycle
    
    init(navigationPath: Binding<NavigationPath>) {
        self.navigationPath = navigationPath.wrappedValue
    }
    
    // MARK: Methods
    
    @MainActor
    @ViewBuilder
    func getView(for flow: AppFlow) -> some View {
        switch flow {
        case .stationsList:
            StationsListView()
        case .slectedStation(let station):
            let viewModel = SelectedStationViewModel(station: station)
            SelectedStationView(viewModel: viewModel)
        case .sensorsDetails(let sensor):
            SensorDetailsContainerView(sensor: sensor)
        case .addNewObservedStation:
            createChildCoordinator().start()
        }
    }
    
    func goToStationsList() {
        navigationPath.append(AppFlow.stationsList)
    }
    
    func gotSelectedStation(_ station: Station) {
        navigationPath.append(AppFlow.slectedStation(station))
    }
    
    func goToSensorDetailsView(for sensor: Sensor) {
        fullScreenCover = .sensorsDetails(sensor)
    }
    
    func showAlert(_ alert: AlertModel) {
        alertSubject.send(alert)
    }
    
    func presentAddStationToObserved() {
        fullScreenCover = .addNewObservedStation
    }
    
    func dismiss() {
        fullScreenCover = nil
    }
    
    private func createChildCoordinator() -> some CoordinatorProtocol {
        let dimissHandler: (() -> ()) = { [weak self] in
            self?.dismissSubject.send()
        }
        
        let coordinator = AddStationToObservedCoordinator(
            dimissHandler: dimissHandler,
            alertSubject: alertSubject
        )
        childCoordinator = coordinator
        return coordinator
    }
}
