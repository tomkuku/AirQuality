//
//  CoordinatorInitialNavigationView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 12/06/2024.
//

import Foundation
import SwiftUI
import Combine

struct CoordinatorInitialView<C>: View where C: CoordinatorBase & CoordinatorProtocol {
    
    @ObservedObject private var coordinator: C
    
    var body: some View {
        coordinator.startView()
            .fullScreenCover(item: $coordinator.fullScreenCover, onDismiss: {
                coordinator.presentationDismissed()
            }, content: { navigationComponent in
                coordinator.createView(for: navigationComponent)
                    .environmentObject(coordinator)
            })
    }
    
    init(coordinator: C) {
        self._coordinator = ObservedObject(wrappedValue: coordinator)
    }
}
