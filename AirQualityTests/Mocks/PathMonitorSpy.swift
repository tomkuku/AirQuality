//
//  PathMonitorMock.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 26/09/2024.
//

import Foundation
import Network

@testable import AirQuality

final class PathMonitorSpy: NWPathMonitorProtocol, @unchecked Sendable {
    enum Event: Equatable {
        case cancel
        case start
    }
    
    var events: [Event] = []
    
    var pathUpdateHandler: (@Sendable (NWPath) -> Void)?
    
    func start(queue: DispatchQueue) {
        events.append(.start)
    }
    
    func cancel() {
        events.append(.cancel)
    }
}
