//
//  UIApplicationProtocol.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 03/06/2024.
//

import Foundation
import class UIKit.UIApplication
import struct UIKit.UIBackgroundTaskIdentifier

@MainActor
protocol UIApplicationProtocol {
    func beginBackgroundTask(withName taskName: String?, expirationHandler handler: (() -> Void)?) -> UIBackgroundTaskIdentifier
    func endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier)
}

extension UIApplication: UIApplicationProtocol { }
