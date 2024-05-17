//
//  AlertViewModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 17/05/2024.
//

import Foundation
import SwiftUI
import Combine

final class AlertViewModel: ObservableObject, @unchecked Sendable {
    
    @Injected(\.notificationCenter) private var notificationCenter
    
    @MainActor
    @Published var isAnyAlertPresented = false
    
    @MainActor
    var alerts: [AlertModel] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() { 
        observeIsAnyAlertPresented()
        observeAletNotifications()
    }
    
    // MARK: Private methods
    
    private func observeIsAnyAlertPresented() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            
            let stream = self.$isAnyAlertPresented.eraseToAnyPublisher().createAsyncStream(&cancellables)
            
            for await value in stream where !value {
                if !alerts.isEmpty {
                    alerts.removeFirst()
                }
                checkIsAnyAlertLeftToPresent()
            }
        }
    }
    
    private func observeAletNotifications() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            
            for await notification in self.notificationCenter.notifications(named: .alert) {
                guard
                    let userInfo = notification.userInfo?[String(describing: AlertModel.self)],
                    let alert = userInfo as? AlertModel
                else {
                    continue
                }
                
                await MainActor.run { [weak self] in
                    self?.alerts.append(alert)
                    self?.checkIsAnyAlertLeftToPresent()
                }
            }
        }
    }
    
    @MainActor
    private func checkIsAnyAlertLeftToPresent() {
        guard let alert = alerts.first else { return }
        
        isAnyAlertPresented = true
    }
}
