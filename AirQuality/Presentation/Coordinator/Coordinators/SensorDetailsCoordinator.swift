//
//  SensorDetailsCoordinator.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 08/06/2024.
//

import Foundation
import SwiftUI

extension SensorDetailsCoordinator {
    enum NavigationComponent: Identifiable, Hashable {
        case containerView
        
        var id: Int {
            switch self {
            case .containerView: 1
            }
        }
    }
}

final class SensorDetailsCoordinator: CoordinatorBase, CoordinatorProtocol {
    
    var fullScreenCover: NavigationComponent?
    let sensor: Sensor
    
    init(
        coordinatorNavigationType: CoordinatorNavigationType,
        sensor: Sensor
    ) {
        self.sensor = sensor
        
        super.init(coordinatorNavigationType: coordinatorNavigationType)
    }
    
    func startView() -> some View {
        createView(for: .containerView)
            .environmentObject(self)
    }
    
    func createView(for navigationComponent: NavigationComponent) -> some View {
        switch navigationComponent {
        case .containerView:
            SensorDetailsContainerView(sensor: sensor)
        }
    }
    
    func goTo(_ navigationComponent: NavigationComponent) { }
}
