//
//  NetworkConnectionMonitorUseCase.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 20/09/2024.
//

import Foundation
import Network

protocol NWPathMonitorProtocol: Sendable, AnyObject {
    @preconcurrency var pathUpdateHandler: (@Sendable (_ newPath: NWPath) -> Void)? { get set }
    
    func start(queue: DispatchQueue)
    func cancel()
}

extension NWPathMonitor: NWPathMonitorProtocol { }

final class NetworkConnectionMonitorUseCase: Sendable {
    
    // MARK: Private properties
    
    private let queue = DispatchQueue(label: "com.NetworkConnectionMonitorUseCase")
    private let pathMonitor: NWPathMonitorProtocol
    
    // MARK: Lifecycle
    
    init(pathMonitor: NWPathMonitorProtocol = NWPathMonitor()) {
        self.pathMonitor = pathMonitor
    }
    
    deinit {
        pathMonitor.cancel()
    }
    
    // MARK: Methods
    
    func startMonitor(noConnectionBlock: @Sendable @escaping () -> ()) {
        pathMonitor.pathUpdateHandler = { path in
            if path.status != .satisfied {
                noConnectionBlock()
            }
        }
        
        pathMonitor.start(queue: self.queue)
    }
}
