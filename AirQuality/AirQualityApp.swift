//
//  AirQualityApp.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 24/04/2024.
//

import SwiftUI

@main
struct AirQualityApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var appCoordinator: AppCoordinator
    
    var body: some Scene {
        WindowGroup {
                if ProcessInfo.isTest {
                    Text("Tests")
                } else {
                    CoordinatorInitialNavigationView(coordinator: appCoordinator)
                        .coordinateSpace(name: "Custom")
                }
        }
    }
    
    init() {
        let coordinator = AppCoordinator(coordinatorNavigationType: .presentation(dismissHandler: { }))
        self._appCoordinator = StateObject(wrappedValue: coordinator)
    }
}
