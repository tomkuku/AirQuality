//
//  AirQualityApp.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 24/04/2024.
//

import SwiftUI
import Combine

@main
struct AirQualityApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var appCoordinator: AppCoordinator
    @StateObject private var alertsCoordinator: AlertsCoordinator
    
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
        let alertsSubject = PassthroughSubject<AlertModel, Never>()
        
        let alertsCoordinator = AlertsCoordinator(alertsPublisher: alertsSubject.eraseToAnyPublisher())
        let appCoordinator = AppCoordinator(coordinatorNavigationType: .presentation(dismissHandler: { }), alertSubject: alertsSubject)
        
        self._appCoordinator = StateObject(wrappedValue: appCoordinator)
        self._alertsCoordinator = StateObject(wrappedValue: alertsCoordinator)
    }
}

extension UIApplication {
    var keyWindowScene: UIWindowScene? {
        self
        .connectedScenes
        .filter { $0.activationState == .foregroundActive }
        .first(where: { $0 is UIWindowScene })
        .flatMap({ $0 as? UIWindowScene })
    }
}
