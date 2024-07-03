//
//  AddStationToObservedCoordinator.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 25/05/2024.
//

import Foundation
import SwiftUI
import Combine

extension AddStationToObservedCoordinator {
    enum NavigationComponent: Identifiable, Hashable {
        case addObservedStationContainer
        
        var id: UUID {
            UUID()
        }
    }
}

@MainActor
final class AddStationToObservedCoordinator: CoordinatorBase, CoordinatorProtocol {
    
    // MARK: Properties
    
    @Published var fullScreenCover: NavigationComponent?
    
    private(set) lazy var addObservedStationListCoordinator = AddObservedStationListCoordinator(coordinatorNavigationType: .push(
        navigationPath: .init(),
        dismissHandler: dismissHandler,
        alertSubject: alertSubject,
        toastSubject: toastSubject
    ))
    
    private(set) lazy var addObservedStationMapCoordinator = AddObservedStationMapCoordinator(coordinatorNavigationType: .push(
        navigationPath: .init(),
        dismissHandler: dismissHandler,
        alertSubject: alertSubject,
        toastSubject: toastSubject
    ))
    
    // MARK: Methods
    
    @ViewBuilder
    @MainActor
    func startView() -> some View {
        AddObservedStationContainerView()
            .environmentObject(self)
    }
    
    @ViewBuilder
    @MainActor
    func createView(for navigationComponent: NavigationComponent) -> some View {
        EmptyView()
    }
    
    func goTo(_ navigationComponent: NavigationComponent) { 
        assertionFailure("No navigation for navigationComponent: \(navigationComponent)!")
    }
}
