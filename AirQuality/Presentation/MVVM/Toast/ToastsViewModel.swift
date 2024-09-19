//
//  ToastsViewModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 29/05/2024.
//

import Foundation
import Combine

final class ToastsViewModel: ObservableObject, @unchecked Sendable {
    @Published var toasts: [Toast] = []
    @Published var presentedToasts: [Toast] = []
    
    private let toastsPublisher: AnyPublisher<Toast, Never>
    private var cancellables = Set<AnyCancellable>()
    
    private let operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.underlyingQueue = .main
        return operationQueue
    }()
    
    init(_ toastsPublisher: AnyPublisher<Toast, Never>) {
        self.toastsPublisher = toastsPublisher
        
        self.subscribeToasts()
    }
        
    private func subscribeToasts() {
        toastsPublisher
            .receive(on: operationQueue)
            .sink { [weak self] toast in
                self?.toasts.append(toast)
            }
            .store(in: &cancellables)
    }
    
    func removeToast(_ toast: Toast) {
        operationQueue.addOperation { [weak self] in
            self?.toasts.removeAll(where: { toast.id == $0.id })
        }
    }
}
