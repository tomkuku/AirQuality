//
//  AlertViewModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 17/05/2024.
//

import Foundation
import SwiftUI
@preconcurrency import Combine

final class AlertViewModel: ObservableObject, @unchecked Sendable {
    
    @Injected(\.notificationCenter) private var notificationCenter
    
    @MainActor
    @Published var isAnyAlertPresented = false
    
    @MainActor
    var alerts: [AlertModel] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init<T>(
        _ alertPublisher: T
    ) where T: Publisher, T.Output == AlertModel, T.Failure == Never {
        observeIsAnyAlertPresented()
        subscribeAlertPublisher(alertPublisher)
    }
    
    // MARK: Private methods
    
    private func observeIsAnyAlertPresented() {
        $isAnyAlertPresented
            .filter { !$0 }
            .asyncSink { @MainActor [weak self] value in
                guard let self else { return }
                
                if !alerts.isEmpty {
                    alerts.removeFirst()
                }
                
                checkIsAnyAlertLeftToPresent()
            }
            .store(in: &cancellables)
    }
    
    private func subscribeAlertPublisher<T>(
        _ alertPublisher: T
    ) where T: Publisher, T.Output == AlertModel, T.Failure == Never {
        alertPublisher
            .asyncSink { @MainActor [weak self] alert in
                self?.alerts.append(alert)
                self?.checkIsAnyAlertLeftToPresent()
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    private func checkIsAnyAlertLeftToPresent() {
        guard !alerts.isEmpty else { return }
        
        isAnyAlertPresented = true
    }
}
