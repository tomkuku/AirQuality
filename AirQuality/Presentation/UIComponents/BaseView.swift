//
//  BaseView.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 08/06/2024.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class BaseViewModel: ObservableObject {
    // swiftlint:disable private_subject
    let alertSubject = PassthroughSubject<AlertModel, Never>()
    let toastSubject = PassthroughSubject<Toast, Never>()
    // swiftlint:enable private_subject
    
    var isLoading = false
}

struct BaseView<C, V, VM>: View 
where C: CoordinatorBase & CoordinatorProtocol, V: View, VM: BaseViewModel {
    
    @ObservedObject private var coordinator: C
    @ObservedObject private var viewModel: VM
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    
                    VStack(spacing: 8) {
                        ProgressView()
                            .progressViewStyle(.circular)
                        
                        Text("Pobieranie danych")
                    }
                    
                    
                    Spacer()
                }
            } else {
                contentView
            }
        }
        .onReceive(viewModel.alertSubject.eraseToAnyPublisher()) { alert in
            coordinator.alertSubject.send(alert)
        }
        .onReceive(viewModel.toastSubject.eraseToAnyPublisher()) { toast in
            coordinator.toastSubject.send(toast)
        }
    }
    
    private var contentView: V
    
    init(viewModel: VM, coordinator: C, contentView: @escaping () -> V) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        self.contentView = contentView()
    }
}
