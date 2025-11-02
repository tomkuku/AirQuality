//
//  NWPathMonitorProtocol.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 18/11/2024.
//

import Foundation
import Network

protocol NWPathMonitorProtocol: Sendable, AnyObject {
    @preconcurrency var pathUpdateHandler: (@Sendable (_ newPath: NWPath) -> Void)? { get set }
    
    var currentPath: NWPath { get }
    
    func start(queue: DispatchQueue)
    func cancel()
}

extension NWPathMonitor: NWPathMonitorProtocol { }
