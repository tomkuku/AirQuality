//
//  NetworkConnectionMonitorUseCasePreviewDummy.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 29/01/2025.
//

import Foundation
import Network

final class NetworkConnectionMonitorUseCasePreviewDummy: NetworkConnectionMonitorUseCaseProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var isConnectionSatisfiedReturnValue: Bool = true
    
    var isConnectionSatisfied: Bool {
        get async {
            Self.isConnectionSatisfiedReturnValue
        }
    }
    
    func startMonitor(noConnectionBlock: @Sendable @escaping () -> ()) async {
        fatalError("`startMonitor(noConnectionBlock:)` is not implemented!")
    }
}
