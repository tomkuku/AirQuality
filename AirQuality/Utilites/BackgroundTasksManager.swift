//
//  BackgroundTasksManager.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 03/06/2024.
//

import Foundation
import struct UIKit.UIBackgroundTaskIdentifier

@MainActor
protocol BackgroundTasksManagerProtocol: Sendable {
    func beginFiniteLengthTask(_ name: String, completion: (@Sendable () -> ())?)
    func endFiniteLengthTask(_ name: String)
}

extension BackgroundTasksManagerProtocol {
    func beginFiniteLengthTask(_ name: String = #fileID, completion: (@Sendable () -> ())? = nil) {
        beginFiniteLengthTask(name, completion: completion)
    }
    
    func endFiniteLengthTask(_ name: String = #fileID) {
        endFiniteLengthTask(name)
    }
}

@MainActor
final class BackgroundTasksManager: BackgroundTasksManagerProtocol, Sendable {
    private let uiApplication: UIApplicationProtocol
    private var identifiers: [String: UIBackgroundTaskIdentifier] = [:]
    
    init(uiApplication: UIApplicationProtocol) {
        self.uiApplication = uiApplication
    }
    
    func beginFiniteLengthTask(_ name: String, completion: (@Sendable () -> ())?) {
        guard !identifiers.contains(where: { $0.key == name }) else {
            Logger.error("There is already task with name: \(name)!")
            completion?()
            return
        }
        
        let identifier = uiApplication.beginBackgroundTask(withName: name) { [weak self] in
            completion?()
            self?.endFiniteLengthTask(name)
        }
        
        identifiers[name] = identifier
    }
    
    func endFiniteLengthTask(_ name: String) {
        guard let identifier = identifiers[name] else {
            Logger.info("No task's identifier with name: \(name)")
            return
        }
        
        identifiers.removeValue(forKey: name)
        uiApplication.endBackgroundTask(identifier)
    }
}
