//
//  NetworkConnectionMonitorRepository.swift
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

protocol NetworkConnectionMonitorRepositoryProtocol: Sendable, AnyObject {
    func startMonitoring() -> AsyncStream<Bool>
    func cancelMonitoring()
}

final class NetworkConnectionMonitorRepository: NetworkConnectionMonitorRepositoryProtocol {
    
    private let queue = DispatchQueue(label: "com.network.connection.monitor.repository")
    private let pathMonitor: NWPathMonitorProtocol
    
    init(pathMonitor: NWPathMonitorProtocol = NWPathMonitor()) {
        self.pathMonitor = pathMonitor
    }
    
    func startMonitoring() -> AsyncStream<Bool> {
        AsyncStream { [weak self] continuation in
            guard let self else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                print("No connection")
                continuation.yield(false)
            }
            
            self.pathMonitor.pathUpdateHandler = { path in
                if path.status == .satisfied {
                    continuation.yield(true)
                } else {
                    continuation.yield(false)
                }
            }
            
            self.pathMonitor.start(queue: self.queue)
        }
    }
    
    func cancelMonitoring() {
        pathMonitor.cancel()
    }
}
