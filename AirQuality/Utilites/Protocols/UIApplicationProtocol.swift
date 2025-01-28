//
//  UIApplicationProtocol.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 03/06/2024.
//

import Foundation
import UIKit

protocol HasUIApplication {
    var uiApplication: UIApplicationProtocol { get }
}

@MainActor
protocol UIApplicationProtocol {
    nonisolated func beginBackgroundTask(
        withName taskName: String?,
        expirationHandler handler: (@MainActor @Sendable () -> Void)?
    ) -> UIBackgroundTaskIdentifier
    
    nonisolated func endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier)
    
    nonisolated func canOpenURL(_ url: URL) -> Bool
    
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any]) async -> Bool
}

/// It's a workaround for Xcode 16
final class UIApplicationWrapper: UIApplicationProtocol {
    nonisolated func beginBackgroundTask(
        withName taskName: String?,
        expirationHandler handler: (@MainActor @Sendable () -> Void)?
    ) -> UIBackgroundTaskIdentifier {
        UIApplication.shared.beginBackgroundTask(withName: taskName, expirationHandler: handler)
    }
    
    func endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier) {
        UIApplication.shared.endBackgroundTask(identifier)
    }
    
    func canOpenURL(_ url: URL) -> Bool {
        UIApplication.shared.canOpenURL(url)
    }
    
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any]) async -> Bool {
        await UIApplication.shared.open(url, options: options)
    }
}
