//
//  CoordinatorBase.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 08/06/2024.
//

import Foundation
import SwiftUI
import Combine

protocol CoordinatorProtocol: ObservableObject {
    associatedtype NavigationComponentType: Identifiable, Hashable
    associatedtype StartViewType: View
    associatedtype CreateViewType: View
    
    var fullScreenCover: NavigationComponentType? { get set }
    
    @ViewBuilder
    @MainActor
    func startView() -> StartViewType
    
    var navigationComponentStart: NavigationComponentType { get}
    
    @ViewBuilder
    @MainActor
    func createView(for navigationComponent: NavigationComponentType) -> CreateViewType
}

enum CoordinatorNavigationType {
    case presentation(dimissHandler: () -> ())
    
    case push(
        navigationPath: NavigationPath,
        alertSubject: any Subject<AlertModel, Never>,
        toastSubject: any Subject<Toast, Never>
    )
}

class CoordinatorBase: ObservableObject {
    @Published var navigationPath: NavigationPath
    
    var alertPublisher: AnyPublisher<AlertModel, Never> {
        alertSubject.eraseToAnyPublisher()
    }
    
    var toastPublisher: AnyPublisher<Toast, Never> {
        toastSubject.eraseToAnyPublisher()
    }
    
    let dimissHandler: (() -> ())?
    let alertSubject: any Subject<AlertModel, Never>
    let toastSubject: any Subject<Toast, Never>
    
    var childCoordinator: (any ObservableObject)?
    
    // MARK: Lifecycle
    
    required init(
        coordinatorNavigationType: CoordinatorNavigationType
    ) {
        switch coordinatorNavigationType {
        case .presentation(let dimissHandler):
            self.navigationPath = .init()
            self.dimissHandler = dimissHandler
            self.alertSubject = PassthroughSubject<AlertModel, Never>()
            self.toastSubject = PassthroughSubject<Toast, Never>()
            
        case .push(let navigationPath, let alertSubject, let toastSubject):
            self.navigationPath = navigationPath
            self.dimissHandler = nil
            self.alertSubject = alertSubject
            self.toastSubject = toastSubject
        }
    }
    
    func showAlert(_ alert: AlertModel) {
        alertSubject.send(alert)
    }
    
    func showToast(_ toast: Toast) {
        toastSubject.send(toast)
    }
}
