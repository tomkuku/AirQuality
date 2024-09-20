//
//  SensorDetailsCoordinator.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 08/06/2024.
//

import Foundation
import SwiftUI
import Combine

extension SensorDetailsCoordinator {
    enum NavigationComponent: CoordinatorNavigationComponentProtocol {
        case containerView
    }
}

final class SensorDetailsCoordinator: CoordinatorBase, CoordinatorProtocol {
    
    var fullScreenCover: NavigationComponent?
    let sensor: Sensor
    
    init<C>(
        childOf parentCoordinator: C,
        navigationType: CoordinatorNavigationType,
        sensor: Sensor
    ) where C: CoordinatorBase & CoordinatorProtocol {
        self.sensor = sensor
        
        super.init(childOf: parentCoordinator, navigationType: navigationType)
    }
    
    @ViewBuilder
    @MainActor
    func startView() -> some View {
        createView(for: .containerView)
            .environmentObject(self)
    }
    
    @ViewBuilder
    @MainActor
    func createView(for navigationComponent: NavigationComponent) -> some View {
        switch navigationComponent {
        case .containerView:
            SensorDetailsContainerView(sensor: sensor)
        }
    }
    
    func goTo(_ navigationComponent: NavigationComponent) { }
}
