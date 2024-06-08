//
//  CoordinatorInitialView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 08/06/2024.
//

import Foundation
import SwiftUI

struct CoordinatorInitialView<C>: View where C: CoordinatorBase & CoordinatorProtocol {
    
    @ObservedObject private var coordinator: C
    @ObservedObject private var alertViewModel: AlertViewModel
    @ObservedObject private var toastsViewModel: ToastsViewModel
    
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
            
            Spacer()
            
            ToastView(toastsViewModel: toastsViewModel)
                .allowsHitTesting(false)
                .background(.clear)
            
            AlertView(viewModel: alertViewModel)
                .allowsHitTesting(false)
                .background(.clear)
                .frame(width: .zero, height: .zero)
        }
    }
    
    init(coordinator: C) {
        let alertViewModel = AlertViewModel(coordinator.alertPublisher)
        let toastsViewModel = ToastsViewModel(coordinator.toastPublisher)
        
        self._coordinator = ObservedObject(wrappedValue: coordinator)
        self._alertViewModel = ObservedObject(wrappedValue: alertViewModel)
        self._toastsViewModel = ObservedObject(wrappedValue: toastsViewModel)
    }
}
