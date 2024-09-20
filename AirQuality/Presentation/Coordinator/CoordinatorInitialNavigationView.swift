//
//  CoordinatorInitialNavigationView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 08/06/2024.
//

import Foundation
import SwiftUI

struct CoordinatorInitialNavigationView<C>: View where C: CoordinatorBase & CoordinatorProtocol {
    
    @ObservedObject private var coordinator: C
    
    private let showToasts: Bool
    private let showAlerts: Bool
    
    var body: some View {
        ZStack {
            NavigationStack(path: $coordinator.navigationPath) {
                coordinator.startView()
                    .navigationDestination(for: C.NavigationComponentType.self) { navigationComponent in
                        coordinator.createView(for: navigationComponent)
                            .environmentObject(coordinator)
                    }
            }
            .fullScreenCover(item: $coordinator.fullScreenCover, onDismiss: {
                coordinator.presentationDismissed()
            }, content: { navigationComponent in
                coordinator.createView(for: navigationComponent)
                    .environmentObject(coordinator)
            })
        }
    }
    
    init(coordinator: C, showAlerts: Bool = true, showToasts: Bool = true) {
        self.showAlerts = showAlerts
        self.showToasts = showToasts
        
        self._coordinator = ObservedObject(wrappedValue: coordinator)
    }
}
