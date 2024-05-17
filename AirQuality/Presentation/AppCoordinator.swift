//
//  AppCoordinator.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import SwiftUI
import Combine

enum AppFlow: Hashable {
    case stationsList
    case slectedStation(Station)
}

final class AppCoordinator: ObservableObject {
    
    @Injected(\.notificationCenter) private var notificationCenter
    
    @Published var navigationPath: NavigationPath
    
    init(navigationPath: Binding<NavigationPath>) {
        self.navigationPath = navigationPath.wrappedValue
    }
    
    @MainActor
    @ViewBuilder
    func getView(for flow: AppFlow) -> some View {
        switch flow {
        case .stationsList:
            StationsListView()
        case .slectedStation(let station):
            let viewModel = SelectedStationViewModel(station: station)
            SelectedStationView(viewModel: viewModel)
        }
    }
    
    func goToStationsList() {
        navigationPath.append(AppFlow.stationsList)
    }
    
    func gotSelectedStation(_ station: Station) {
        navigationPath.append(AppFlow.slectedStation(station))
    }
    
    func showAlert(_ alert: AlertModel) {
        let userInfo = [String(describing: AlertModel.self): alert]
        
        notificationCenter.post(name: .alert, object: alert, userInfo: userInfo)
    }
}
