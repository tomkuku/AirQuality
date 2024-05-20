//
//  AirQualityApp.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 24/04/2024.
//

import SwiftUI

@main
struct AirQualityApp: App {
    
    @StateObject private var appCoordinator: AppCoordinator
    @ObservedObject private var alertViewModel: AlertViewModel
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $appCoordinator.navigationPath) {
                appCoordinator.getView(for: .stationsList)
                    .navigationDestination(for: AppFlow.self) { appFlow in
                        appCoordinator.getView(for: appFlow)
                    }
                    .environmentObject(appCoordinator)
            }
            .fullScreenCover(item: $appCoordinator.fullScreenCover) { route in
                appCoordinator.getView(for: route)
            }
            .environmentObject(appCoordinator)
            
            AlertView(viewModel: alertViewModel)
                .allowsHitTesting(false)
                .background(.red)
                .frame(width: .zero, height: .zero)
        }
    }
    
    init() {
        let appCoordinator = AppCoordinator(navigationPath: .constant(NavigationPath()))
        let alertViewModel = AlertViewModel(appCoordinator.alertPublisher)
        
        self._appCoordinator = StateObject(wrappedValue: appCoordinator)
        self._alertViewModel = ObservedObject(wrappedValue: alertViewModel)
        
        do {
            DependenciesContainerManager.container = try DependenciesContainer()
        } catch {
            fatalError("Could not create DependenciesContainer due to error: \(error.localizedDescription)")
        }
    }
}
