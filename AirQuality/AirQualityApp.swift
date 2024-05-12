//
//  AirQualityApp.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 24/04/2024.
//

import SwiftUI

@main
struct AirQualityApp: App {
    
    @StateObject private var appCoordinator = AppCoordinator(navigationPath: .constant(NavigationPath()))
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $appCoordinator.navigationPath) {
                appCoordinator.getView(for: .stationsList)
                    .navigationDestination(for: AppFlow.self) { appFlow in
                        appCoordinator.getView(for: appFlow)
                    }
                    .environmentObject(appCoordinator)
            }
        }
    }
    
    init() {
        DependenciesContainerManager.container = DependenciesContainer()
    }
}

//struct CoordinatorView<T: View>: View {
//    
//    @StateObject private var coordinator: DashboardCoordinator
//    
//    private let contentView: T
//    
//    var body: some View {
//        contentView
//    }
//    
//    init(coordinator: DashboardCoordinator, contentView: () -> T) {
//        self._coordinator = StateObject(wrappedValue: coordinator)
//        self.contentView = contentView()
//    }
//}
