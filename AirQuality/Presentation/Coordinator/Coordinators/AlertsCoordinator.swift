//
//  AlertCoordinator.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 18/09/2024.
//

import Foundation
import UIKit
import SwiftUI
import Combine

@MainActor
protocol AlertsCoordinatorViewModelDelegate: AnyObject {
    func alertsViewModelHaveNoAlertsInQueue()
    func alertsViewModelReceivedAlert()
}

@MainActor
final class AlertsCoordinator: ObservableObject {
    
    private var window: UIWindow?
    private let alertViewModel: AlertViewModel
    private var sceneDidActivateNotificationCancelablle: AnyCancellable?
    
    init(alertsPublisher: AnyPublisher<AlertModel, Never>) {
        self.alertViewModel = AlertViewModel(alertsPublisher)
        self.alertViewModel.delegate = self
        
        observeWhenAppSceneDidActive()
    }
    
    private func observeWhenAppSceneDidActive() {
        /// Waits until app scene become active to get `windowScene` required to create a new window.
        sceneDidActivateNotificationCancelablle = NotificationCenter.default.publisher(for: UIScene.didActivateNotification)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                
                guard let windowScene = UIApplication.shared.keyWindowScene else {
                    assertionFailure("No windowScene!")
                    return
                }
                
                let alertView = AlertView(viewModel: self.alertViewModel)
                
                let hostingController = UIHostingController(rootView: alertView)
                hostingController.view.backgroundColor = .clear
                
                self.window = UIWindow(windowScene: windowScene)
                self.window?.rootViewController = hostingController
                self.window?.windowLevel = .alert
                
                self.sceneDidActivateNotificationCancelablle?.cancel()
                self.sceneDidActivateNotificationCancelablle = nil
            }
    }
}

extension AlertsCoordinator: AlertsCoordinatorViewModelDelegate {
    func alertsViewModelHaveNoAlertsInQueue() {
        window?.isHidden = true
    }
    
    func alertsViewModelReceivedAlert() {
        if window?.isKeyWindow == false {
            window?.makeKeyAndVisible()
        } else {
            window?.isHidden = false
        }
    }
}
