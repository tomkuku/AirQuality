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

final class AddStationToObservedCoordinator: CoordinatorBase, CoordinatorProtocol {
    
    // MARK: Properties
    
    @Published var fullScreenCover: NavigationComponent?
    
    // MARK: Methods
    
    @ViewBuilder
    @MainActor
    func startView() -> some View {
        createView(for: .addObservedStationContainer)
    }
    
    @ViewBuilder
    @MainActor
    func createView(for navigationComponent: NavigationComponent) -> some View {
        switch navigationComponent {
        case .addObservedStationContainer:
            AddObservedStationContainerView()
                .environmentObject(self)
        }
    }
    
    func goTo(_ navigationComponent: NavigationComponent) { }
}
