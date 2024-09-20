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
    @StateObject private var toastsCoordinator: ToastsCoordinator
    
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
        let toastsSubject = PassthroughSubject<ToastModel, Never>()
        
        let toastsCoordinator = ToastsCoordinator(toastsPublisher: toastsSubject.eraseToAnyPublisher())
        let alertsCoordinator = AlertsCoordinator(alertsPublisher: alertsSubject.eraseToAnyPublisher())
        let appCoordinator = AppCoordinator(
            coordinatorNavigationType: .presentation(dismissHandler: {}),
            alertSubject: alertsSubject,
            toastSubject: toastsSubject
        )
        
        self._appCoordinator = StateObject(wrappedValue: appCoordinator)
        self._alertsCoordinator = StateObject(wrappedValue: alertsCoordinator)
        self._toastsCoordinator = StateObject(wrappedValue: toastsCoordinator)
    }
}

extension UIApplication {
    var keyWindowScene: UIWindowScene? {
        self
            .connectedScenes
            .first(where: { $0.activationState == .foregroundActive && $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })
    }
}
