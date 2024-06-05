//
//  UIApplicationProtocol.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 03/06/2024.
//

import Foundation
import class UIKit.UIApplication
import struct UIKit.UIBackgroundTaskIdentifier

protocol UIApplicationProtocol {
    @MainActor
    func beginBackgroundTask(withName taskName: String?, expirationHandler handler: (() -> Void)?) -> UIBackgroundTaskIdentifier
    
    @MainActor
    func endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier)
}

extension UIApplication: UIApplicationProtocol { }
