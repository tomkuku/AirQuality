//
//  NetworkConnectionMonitorUseCaseSpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 18/11/2024.
//

import Foundation
import XCTest

@testable import AirQuality

final class NetworkConnectionMonitorUseCaseSpy: NetworkConnectionMonitorUseCaseProtocol, @unchecked Sendable {
    
    enum Event {
        case isConnectionSatisfied
        case startMonitor
    }
    
    var events: [Event] = []
    
    var isConnectionSatisfiedReturnValue: Bool = false
    
    // MARK: Protocol requirements
    
    var isConnectionSatisfied: Bool {
        get async {
            events.append(.isConnectionSatisfied)
            
            return isConnectionSatisfiedReturnValue
        }
    }
    
    func startMonitor(noConnectionBlock: @Sendable @escaping () -> ()) async {
        events.append(.startMonitor)
        
        XCTFail("startMonitor requires implementation!")
    }
}
