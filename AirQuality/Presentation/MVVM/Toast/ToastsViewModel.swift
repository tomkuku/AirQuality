//
//  ToastsViewModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 29/05/2024.
//

import Foundation
import Combine

final class ToastsViewModel: ObservableObject, @unchecked Sendable {
    
    // MARK: Properties
    
    @Published var toasts: [ToastModel] = []
    
    private let toastsPublisher: AnyPublisher<ToastModel, Never>
    private var cancellables = Set<AnyCancellable>()
    
    private let operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.underlyingQueue = .main
        return operationQueue
    }()
    
    // MARK: Lifecycle
    
    init(_ toastsPublisher: AnyPublisher<ToastModel, Never>) {
        self.toastsPublisher = toastsPublisher
        
        self.subscribeToasts()
    }
    
    // MARK: Methods
    
    func removeToast(_ toast: ToastModel) {
        operationQueue.addOperation { [weak self] in
            self?.toasts.removeAll(where: { toast.id == $0.id })
        }
    }
    
    // MARK: Private methods
    
    private func subscribeToasts() {
        toastsPublisher
            .receive(on: operationQueue)
            .sink { [weak self] toast in
                self?.toasts.append(toast)
            }
            .store(in: &cancellables)
    }
}
