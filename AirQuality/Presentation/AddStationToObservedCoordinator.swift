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
    
    private let dimissHandler: (() -> ())?
    private let alertSubject: any Subject<AlertModel, Never>
    
    @Published var navigationPath = NavigationPath()
    
    init(
        dimissHandler: @escaping () -> (),
        alertSubject: any Subject<AlertModel, Never>
    ) {
        self.dimissHandler = dimissHandler
        self.alertSubject = alertSubject
    }
    
    func start() -> some View {
        AddStationToObservedListView()
            .environmentObject(self)
    }
    
    func createView(for navigationComponent: NavigationComponent) -> some View {
        switch navigationComponent {
        case .statinsList:
            let viewModel = StationsListViewModel()
            StationsListView(viewModel: viewModel)
                .environmentObject(self)
        case .stationsMap:
            EmptyView()
        }
    }
    
    func dismiss() {
        dimissHandler?()
    }
    
    func showAlert(_ alert: AlertModel) {
        alertSubject.send(alert)
    }
}
