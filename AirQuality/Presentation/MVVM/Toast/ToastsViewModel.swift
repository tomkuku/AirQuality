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
    
    private let toastsPublisher: any Publisher<Toast, Never>
    
    private var cancellables = Set<AnyCancellable>()
    
    init(_ toastsPublisher: any Publisher<Toast, Never>) {
        self.toastsPublisher = toastsPublisher
        
        self.subscribeToasts()
    }
        
    private func subscribeToasts() {
        toastsPublisher
            .asyncSink { @MainActor [weak self] toast in
                self?.toasts.append(toast)
                self?.addDismissToastAction()
            }
            .store(in: &cancellables)
    }
    
    private func addDismissToastAction() {
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
            
            self?.toasts.removeFirst()
        }
    }
}
