//
//  BackgroundTasksManager.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 03/06/2024.
//

import Foundation
import struct UIKit.UIBackgroundTaskIdentifier

protocol BackgroundTasksManagerProtocol: Sendable {
    @MainActor
    func beginFiniteLengthTask(_ name: String, completion: (@Sendable () -> ())?)
    
    @MainActor
    func endFiniteLengthTask(_ name: String)
}

extension BackgroundTasksManagerProtocol {
    @MainActor
    func beginFiniteLengthTask(_ name: String = #fileID, completion: (@Sendable () -> ())? = nil) {
        beginFiniteLengthTask(name, completion: completion)
    }
    
    @MainActor
    func endFiniteLengthTask(_ name: String = #fileID) {
        endFiniteLengthTask(name)
    }
}

final class BackgroundTasksManager: BackgroundTasksManagerProtocol, @unchecked Sendable {
    private let uiApplication: UIApplicationProtocol
    
    @MainActor
    private var identifiers: [String: UIBackgroundTaskIdentifier] = [:]
    
    init(uiApplication: UIApplicationProtocol) {
        self.uiApplication = uiApplication
    }
    
    @MainActor
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
    
    @MainActor
    func endFiniteLengthTask(_ name: String) {
        guard let identifier = identifiers[name] else {
            Logger.info("No task's identifier with name: \(name)")
            return
        }
        
        identifiers.removeValue(forKey: name)
        uiApplication.endBackgroundTask(identifier)
    }
}
