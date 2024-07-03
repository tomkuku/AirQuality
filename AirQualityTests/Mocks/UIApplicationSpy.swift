//
//  UIApplicationSpy.swift
//  AirQualityTests
//
//  Created by Tomasz Kukułka on 03/06/2024.
//

import Foundation
import struct UIKit.UIBackgroundTaskIdentifier
import class UIKit.UIApplication

@testable import AirQuality

final class UIApplicationSpy: UIApplicationProtocol {
    enum Event: Equatable {
        case beginBackgroundTask(String?)
        case endBackgroundTask(UIBackgroundTaskIdentifier)
    }
    
    var events: [Event] = []
    
    var beginBackgroundTaskExpirationHandler: (() -> Void)?
    var beginBackgroundTaskReturnValue: UIBackgroundTaskIdentifier = .invalid
    
    func beginBackgroundTask(withName taskName: String?, expirationHandler handler: (() -> Void)?) -> UIBackgroundTaskIdentifier {
        beginBackgroundTaskExpirationHandler = {
            handler?()
        }
        
        events.append(.beginBackgroundTask(taskName))
        
        return beginBackgroundTaskReturnValue
    }
    
    func endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier) {
        events.append(.endBackgroundTask(identifier))
    }
    
    func canOpenURL(_ url: URL) -> Bool {
        false
    }
    
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any]) async -> Bool {
        false
    }
}
