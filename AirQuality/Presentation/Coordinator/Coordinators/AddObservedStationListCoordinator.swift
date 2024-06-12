//
//  AddObservedStationListCoordinator.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 12/06/2024.
//

import Foundation
import SwiftUI

extension AddObservedStationListCoordinator {
    enum NavigationComponent: CoordinatorNavigationComponentProtocol { }
}

final class AddObservedStationListCoordinator: CoordinatorBase, CoordinatorProtocol {
    
    var fullScreenCover: NavigationComponent?
    
    @ViewBuilder
    @MainActor
    func startView() -> some View {
        AddStationToObservedListView()
            .environmentObject(self)
    }
    
    @ViewBuilder
    @MainActor
    func createView(for navigationComponent: NavigationComponent) -> some View {
        EmptyView()
    }
    
    func goTo(_ navigationComponent: NavigationComponent) { }
}
