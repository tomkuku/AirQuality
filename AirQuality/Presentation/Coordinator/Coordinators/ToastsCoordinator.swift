//
//  ToastsCoordinator.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 19/09/2024.
//

import Foundation
import UIKit
import SwiftUI
import Combine

final class ToastWindow: UIWindow {
    override var canBecomeKey: Bool {
        false
    }
    
    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        
        isHidden = false
        windowLevel = .statusBar
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        nil
    }
}

@MainActor
final class ToastsCoordinator: ObservableObject {
    
    private var window: ToastWindow?
    private let toastsViewModel: ToastsViewModel
    
    private var sceneDidActivateNotificationCancelablle: AnyCancellable?
    
    init(toastsPublisher: AnyPublisher<ToastModel, Never>) {
        self.toastsViewModel = ToastsViewModel(toastsPublisher)
        
        observeAppSceneDidActive()
    }
    
    private func observeAppSceneDidActive() {
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
                
                let toastsView = ToastsView(toastsViewModel: toastsViewModel)
                
                let hostingController = UIHostingController(rootView: toastsView)
                hostingController.view.backgroundColor = .clear
                
                self.window = ToastWindow(windowScene: windowScene)
                self.window?.rootViewController = hostingController
                
                self.sceneDidActivateNotificationCancelablle?.cancel()
                self.sceneDidActivateNotificationCancelablle = nil
            }
    }
}
