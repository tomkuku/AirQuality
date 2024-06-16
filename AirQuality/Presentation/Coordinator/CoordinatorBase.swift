//
//  CoordinatorBase.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 08/06/2024.
//

import Foundation
import SwiftUI
import Combine

enum CoordinatorNavigationType {
    case presentation(dismissHandler: () -> ())
    
    case push(
        navigationPath: NavigationPath,
        dismissHandler: (() -> ())? = nil,
        alertSubject: any Subject<AlertModel, Never>,
        toastSubject: any Subject<Toast, Never>
    )
}

class CoordinatorBase: ObservableObject {
    
    // MARK: Properties
    
    @Published var navigationPath: NavigationPath
    
    var alertPublisher: AnyPublisher<AlertModel, Never> {
        alertSubject.eraseToAnyPublisher()
    }
    
    var toastPublisher: AnyPublisher<Toast, Never> {
        toastSubject.eraseToAnyPublisher()
    }
    
    let alertSubject: any Subject<AlertModel, Never>
    let toastSubject: any Subject<Toast, Never>
    
    var childCoordinator: (any ObservableObject)?
    
    // MARK: Private properties
    
    /// Closure which executes dismiss coordinator (self) if it's presented by sheet or fullScreenCover.
    let dismissHandler: (() -> ())?
    
    // MARK: Lifecycle
    
    init(
        coordinatorNavigationType: CoordinatorNavigationType
    ) {
        switch coordinatorNavigationType {
        case .presentation(let dimissHandler):
            self.navigationPath = .init()
            self.dismissHandler = dimissHandler
            self.alertSubject = PassthroughSubject<AlertModel, Never>()
            self.toastSubject = PassthroughSubject<Toast, Never>()
            
        case .push(let navigationPath, let dismissHandler, let alertSubject, let toastSubject):
            self.navigationPath = navigationPath
            self.dismissHandler = dismissHandler
            self.alertSubject = alertSubject
            self.toastSubject = toastSubject
        }
    }
    
    // MARK: Methods
    
    /// It dismisses coordinator (self) if it's presented (sheet or fullScreenCover).
    func dismiss() {
        dismissHandler?()
    }
    
    /// It handles completion after presented coordinator by this coordinator.
    func presentationDismissed() {
        childCoordinator = nil
    }
    
    func showAlert(_ alert: AlertModel) {
        alertSubject.send(alert)
    }
    
    func showToast(_ toast: Toast) {
        toastSubject.send(toast)
    }
}
