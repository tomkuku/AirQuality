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
        case getCurrentPath
    }
    
    var events: [Event] = []
    
    var pathUpdateHandler: (@Sendable (NWPath) -> Void)?
    var currentPathReturnValue: NWPath?
    
    // MARK: Protocol properties
    
    var currentPath: NWPath {
        events.append(.getCurrentPath)
        
        guard let currentPathReturnValue else {
            fatalError("currentPath requires non nil currentPathReturnValue value!")
        }
        
        return currentPathReturnValue
    }
    
    // MARK: Protocol methods
    
    func start(queue: DispatchQueue) {
        events.append(.start)
    }
    
    func cancel() {
        events.append(.cancel)
    }
}
