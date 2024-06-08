//
//  AddStationToObservedCoordinator.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 25/05/2024.
//

import Foundation
import SwiftUI
import Combine

extension AddStationToObservedCoordinator {
    enum NavigationComponent: Identifiable {
        case statinsList
        case stationsMap
        
        var id: UUID {
            UUID()
        }
    }
}

final class AddStationToObservedCoordinator: CoordinatorProtocol {
    
    // MARK: Properties
    
    @Published var navigationPath = NavigationPath()
    
    // MARK: Private properties
    
    private let dimissHandler: () -> ()
    private let alertSubject: any Subject<AlertModel, Never>
    private let toastSubject: any Subject<Toast, Never>
    
    private var stationsListViewModel: AddStationToObservedListViewModel?
    private var stationsMapViewModel: AddObservedStationMapViewModel?
    
    // MARK: Lifecycle
    
    init(
        dimissHandler: @escaping () -> (),
        alertSubject: any Subject<AlertModel, Never>,
        toastSubject: any Subject<Toast, Never>
    ) {
        self.dimissHandler = dimissHandler
        self.alertSubject = alertSubject
        self.toastSubject = toastSubject
    }
    
    // MARK: Methods
    
    func start() -> some View {
        AddStationToObservedContainerView()
            .environmentObject(self)
    }
    
    func createView(for navigationComponent: NavigationComponent) -> some View {
        switch navigationComponent {
        case .statinsList:
            let viewModel = getAddStationToObservedListViewModel()
            
            AddStationToObservedListView(viewModel: viewModel)
                .environmentObject(self)
        case .stationsMap:
            let viewModel = getAddObservedStationMapViewModel()
            
            AddObservedStationMapView(viewModel: viewModel)
                .environmentObject(self)
        }
    }
    
    func dismiss() {
        dimissHandler()
    }
    
    func showAlert(_ alert: AlertModel) {
        alertSubject.send(alert)
    }
    
    func showToast(_ toast: Toast) {
        toastSubject.send(toast)
    }
    
    // MARK: Private methods
    
    @MainActor
    private func getAddObservedStationMapViewModel() -> AddObservedStationMapViewModel {
        let viewModel: AddObservedStationMapViewModel
        
        if let stationsMapViewModel = self.stationsMapViewModel {
            viewModel = stationsMapViewModel
        } else {
            viewModel = AddObservedStationMapViewModel()
            self.stationsMapViewModel = viewModel
        }
        
        return viewModel
    }
    
    @MainActor
    private func getAddStationToObservedListViewModel() -> AddStationToObservedListViewModel {
        let viewModel: AddStationToObservedListViewModel
        
        if let stationsListViewModel = self.stationsListViewModel {
            viewModel = stationsListViewModel
        } else {
            viewModel = AddStationToObservedListViewModel()
            self.stationsListViewModel = viewModel
        }
        
        return viewModel
    }
}
