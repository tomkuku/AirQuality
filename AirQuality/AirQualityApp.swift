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
    @ObservedObject private var alertViewModel: AlertViewModel
    @ObservedObject private var toastsViewModel: ToastsViewModel
    
    @State private var isFullScreenCoverPresented: Bool = false
    
    @State private var isPresented = true
    @State private var showToast = true
    
    var body: some Scene {
        WindowGroup {
            GeometryReader { _ in
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
                
                ToastView(toastsViewModel: toastsViewModel)
                    .allowsHitTesting(false)
                    .background(.red)
                    .frame(width: .zero, height: .zero)
            }
        }
    }
    
    init() {
        let appCoordinator = AppCoordinator(navigationPath: .init(projectedValue: .constant(NavigationPath())))
        let alertViewModel = AlertViewModel(appCoordinator.alertPublisher)
        let toastsViewModel = ToastsViewModel(appCoordinator.toastPublisher)
        
        self._appCoordinator = StateObject(wrappedValue: appCoordinator)
        self._alertViewModel = ObservedObject(wrappedValue: alertViewModel)
        self._toastsViewModel = ObservedObject(wrappedValue: toastsViewModel)
    }
}
