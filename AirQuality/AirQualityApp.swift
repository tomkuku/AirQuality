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
            CoordinatorInitialView(coordinator: appCoordinator)
        }
    }
    
    init() {
        let coordinator = AppCoordinator(coordinatorNavigationType: .presentation(dimissHandler: { }))
        self._appCoordinator = StateObject(wrappedValue: coordinator)
    }
}
