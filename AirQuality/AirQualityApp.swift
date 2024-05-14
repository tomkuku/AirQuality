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
        do {
            DependenciesContainerManager.container = try DependenciesContainer()
        } catch {
            fatalError("Could not create DependenciesContainer due to error: \(error.localizedDescription)")
        }
    }
}
