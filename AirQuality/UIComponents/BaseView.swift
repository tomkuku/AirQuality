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
    let toastSubject = PassthroughSubject<ToastModel, Never>()
    let errorSubject = PassthroughSubject<Error, Never>()
    // swiftlint:enable private_subject
    
    var isLoading = true
    
    @Injected(\.networkConnectionMonitorUseCase) private var networkConnectionMonitorUseCase
    
    func isLoading(_ isLoading: Bool, objectWillChnage: Bool) {
        guard self.isLoading != isLoading else { return }
        
        self.isLoading = isLoading
        
        if objectWillChnage {
            self.objectWillChange.send()
        }
    }
    
    func sendError(_ error: Error) {
        errorSubject.send(error)
    }
    
    func checkIsInternetConnected() async throws {
        if await !networkConnectionMonitorUseCase.isConnectionSatisfied {
            throw AppError.noInternetConnection
        }
    }
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
            coordinator.showAlert(alert)
        }
        .onReceive(viewModel.toastSubject.eraseToAnyPublisher()) { toast in
            coordinator.showToast(toast)
        }
        .onReceive(viewModel.errorSubject.eraseToAnyPublisher()) { error in
            if let onReceiveError {
                onReceiveError(error)
                return
            }
            
            coordinator.handleError(error)
        }
    }
    
    private var contentView: V
    private var onReceiveError: ((Error) -> ())?
    
    init(
        viewModel: VM,
        coordinator: C,
        onReceiveError: ((Error) -> ())? = nil,
        @ViewBuilder contentView: @escaping () -> V
    ) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        self.onReceiveError = onReceiveError
        self.contentView = contentView()
    }
}

#Preview {
    final class CoordinatorPreviewDummy: CoordinatorBase, CoordinatorProtocol {
        struct NavigationComponent: Identifiable, Hashable {
            let id: Int
        }
        
        var fullScreenCover: NavigationComponent?
        
        convenience init() {
            self.init(
                coordinatorNavigationType: .presentation(dismissHandler: {}),
                alertSubject: .init(),
                toastSubject: .init()
            )
        }
        
        func startView() -> some View {
            Rectangle()
        }
        
        func createView(for navigationComponent: NavigationComponent) -> some View {
            Rectangle()
        }
        
        func goTo(_ navigationComponent: NavigationComponent) { }
    }
    
    let baseViewModel = BaseViewModel()
    baseViewModel.isLoading = true
    
    @StateObject var viewModel = baseViewModel
    @StateObject var coordinator = CoordinatorPreviewDummy()
    
    return BaseView(viewModel: viewModel, coordinator: coordinator) {
        EmptyView()
    }
}
