//
//  AddObservedStationMapCoordinator.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 12/06/2024.
//

import Foundation
import SwiftUI

protocol CoordinatorNavigationComponentProtocol: Identifiable, Hashable where ID == String { }

extension CoordinatorNavigationComponentProtocol {
    var id: String {
        String(describing: self)
    }
}

extension AddObservedStationMapCoordinator {
    enum NavigationComponent: CoordinatorNavigationComponentProtocol { }
}

final class AddObservedStationMapCoordinator: CoordinatorBase, CoordinatorProtocol {
    
    var fullScreenCover: NavigationComponent?
    
    func startView() -> some View {
        AddObservedStationMapView()
            .environmentObject(self)
    }
    
    func createView(for navigationComponent: NavigationComponent) -> some View {
        EmptyView()
    }
    
    func goTo(_ navigationComponent: NavigationComponent) { }
}
