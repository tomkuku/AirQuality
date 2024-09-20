//
//  AlertViewModel.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 17/05/2024.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class AlertViewModel: ObservableObject {
    
    typealias AlertPublisher = AnyPublisher<AlertModel, Never>
    
    /// It only store a state of presented alert.
    /// Publishs false if alert is dismissed.
    /// Publishs true if alerts is not empty.
    var isAnyAlertPresented = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard
                    let self,
                    isAnyAlertPresented != oldValue,
                    !isAnyAlertPresented
                else {
                    return
                }
                
                alerts.first?.dismissAction?()
                
                if !alerts.isEmpty {
                    alerts.removeFirst()
                }
            }
        }
    }
    
    private(set) var alerts: [AlertModel] = [] {
        didSet {
            if oldValue.isEmpty && !alerts.isEmpty { /// Array is not empty now.
                delegate?.alertsViewModelReceivedAlert()
            } else if !oldValue.isEmpty && alerts.isEmpty { /// Array is empty now.
                delegate?.alertsViewModelHaveNoAlertsInQueue()
            }
            
            if !alerts.isEmpty, !isAnyAlertPresented {
                isAnyAlertPresented = true
                objectWillChange.send()
            }
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    /// Delegate required to control the visibility of `AlertView` by widnow on `AlertsCoordinator`.
    weak var delegate: AlertsCoordinatorViewModelDelegate?
    
    init(_ alertPublisher: AlertPublisher) {
        subscribeAlertPublisher(alertPublisher)
    }
    
    // MARK: Private methods
    
    private func subscribeAlertPublisher(_ alertPublisher: AlertPublisher) {
        alertPublisher
            .sink { [weak self] alert in
                self?.alerts.append(alert)
            }
            .store(in: &cancellables)
    }
}
