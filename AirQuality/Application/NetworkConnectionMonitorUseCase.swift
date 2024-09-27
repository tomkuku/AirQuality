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

actor NetworkConnectionMonitorUseCase {
    
    // MARK: Private properties
    
    private let queue = DispatchQueue(label: "com.NetworkConnectionMonitorUseCase")
    private let pathMonitor: NWPathMonitorProtocol
    private var currentStatus: NWPath.Status?
    
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
            Task { [weak self] in
                guard  let self, await self.checkIsStatusChangedToUnsatisfied(path.status) else { return }
                
                noConnectionBlock()
            }
        }
        
        pathMonitor.start(queue: self.queue)
    }
    
    private func checkIsStatusChangedToUnsatisfied(_ newPathStatus: NWPath.Status) -> Bool {
        defer {
            currentStatus = newPathStatus
        }
        
        if let currentStatus, currentStatus == .satisfied && newPathStatus != .satisfied {
            /// Ignore situation when unsatisfied status changes to other `unsatisfied` (e.g. `requiresConnection`).
            return true
        } else if currentStatus == nil && newPathStatus != .satisfied {
            return true
        }
        
        return false
    }
}
