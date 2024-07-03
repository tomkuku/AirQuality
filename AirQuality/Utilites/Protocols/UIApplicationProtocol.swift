//
//  UIApplicationProtocol.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 03/06/2024.
//

import Foundation
import class UIKit.UIApplication
import struct UIKit.UIBackgroundTaskIdentifier

protocol HasUIApplication {
    var uiApplication: UIApplicationProtocol { get }
}

protocol UIApplicationProtocol {
    @MainActor
    func beginBackgroundTask(withName taskName: String?, expirationHandler handler: (() -> Void)?) -> UIBackgroundTaskIdentifier
    
    @MainActor
    func endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier)
    
    @MainActor
    func canOpenURL(_ url: URL) -> Bool
    
    @MainActor
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any]) async -> Bool
}

extension UIApplication: UIApplicationProtocol { }
