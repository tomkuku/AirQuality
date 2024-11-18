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
    /// Use when the new coordinator's start view is being presented modally and it begins navigation path.
    case presentation(dismissHandler: () -> ())
    
    /// Use when the new coordinator's start view is being pushed and navigation path will be continued.
    case push(
        navigationPath: NavigationPath,
        dismissHandler: (() -> ())? = nil
    )
}

@MainActor
class CoordinatorBase: ObservableObject {
    
    // MARK: Properties
    
    @Published var navigationPath: NavigationPath
    
    /// Subjects used to present and alert or toasts.
    /// These subject' references are passed into every new coordinator.
    private let alertSubject: PassthroughSubject<AlertModel, Never>
    private let toastSubject: PassthroughSubject<ToastModel, Never>
    
    var childCoordinator: (any ObservableObject)?
    
    /// Closure which executes dismiss coordinator (self) if it's presented by sheet or fullScreenCover.
    let dismissHandler: (() -> ())?
    
    // MARK: Private properties
    
    @Injected(\.uiApplication) private var uiApplication
    
    // MARK: Lifecycle
    
    init<C>(
        childOf parentCoordinator: C,
        navigationType: CoordinatorNavigationType
    ) where C: CoordinatorBase & CoordinatorProtocol {
        self.alertSubject = parentCoordinator.alertSubject
        self.toastSubject = parentCoordinator.toastSubject
        
        switch navigationType {
        case .presentation(let dimissHandler):
            self.navigationPath = .init()
            self.dismissHandler = dimissHandler
            
        case .push(let navigationPath, let dismissHandler):
            self.navigationPath = navigationPath
            self.dismissHandler = dismissHandler
        }
    }
    
    init(
        coordinatorNavigationType: CoordinatorNavigationType,
        alertSubject: PassthroughSubject<AlertModel, Never>,
        toastSubject: PassthroughSubject<ToastModel, Never>
    ) {
        self.alertSubject = alertSubject
        self.toastSubject = toastSubject
        
        switch coordinatorNavigationType {
        case .presentation(let dimissHandler):
            self.navigationPath = .init()
            self.dismissHandler = dimissHandler
            
        case .push(let navigationPath, let dismissHandler):
            self.navigationPath = navigationPath
            self.dismissHandler = dismissHandler
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
    
    /// Method which can be used to present an alert in views. It makes subject unvisibale for views.
    func showAlert(_ alert: AlertModel) {
        alertSubject.send(alert)
    }
    
    /// Method which can be used to present a toast in views. It makes subject unvisibale for views.
    func showToast(_ toast: ToastModel) {
        toastSubject.send(toast)
    }
    
    func handleError(_ error: Error) {
        guard let appError = error as? AppError else {
            showAlert(.somethigWentWrong())
            return
        }
        
        switch appError {
        case .noInternetConnection:
            showAlert(.noInternetConnection(self))
        }
    }
    
    @MainActor
    func open(url: URL?) {
        Task {
            guard  let url, uiApplication.canOpenURL(url) else {
                alertSubject.send(.somethigWentWrong())
                return
            }
            
            _ = await uiApplication.open(url, options: [:])
        }
    }
}
