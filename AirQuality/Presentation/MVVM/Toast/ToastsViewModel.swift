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
    
    let operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.underlyingQueue = .main
        return operationQueue
    }()
    
    /// Required to wait until a toast animation complete to make sure toasts are presented in FIFO.
    private var presentationAnimationOperationCompletion: CompletableOperation.Completion?
    
    // MARK: Lifecycle
    
    init(_ toastsPublisher: AnyPublisher<ToastModel, Never>) {
        self.toastsPublisher = toastsPublisher
        
        self.subscribeToasts()
    }
    
    // MARK: Methods
    
    func removeToast(_ toast: ToastModel) {
        toasts.removeAll(where: { toast.id == $0.id })
    }
    
    func presentationAnimationDidComplete() {
        presentationAnimationOperationCompletion?()
    }
    
    // MARK: Private methods
    
    private func subscribeToasts() {
        toastsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] toast in
                let operation = CompletableOperation(priority: .normal) { [weak self] completion in
                    self?.presentationAnimationOperationCompletion = completion
                    self?.toasts.append(toast)
                }
                
                self?.operationQueue.addOperation(operation)
            }
            .store(in: &cancellables)
    }
}
