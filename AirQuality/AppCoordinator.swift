//
//  AppCoordinator.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 10/05/2024.
//

import SwiftUI
import Combine

enum AppFlow {
    case stationsList
}

final class AppCoordinator: ObservableObject {
    
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
        }
    }
    
    func goToStationsList() {
        navigationPath.append(AppFlow.stationsList)
    }
}
