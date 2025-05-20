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

final class UIApplicationSpy: UIApplicationProtocol, @unchecked Sendable {
    enum Event: Equatable {
        case beginBackgroundTask(String?)
        case endBackgroundTask(UIBackgroundTaskIdentifier)
    }
    
    final class SendableWrapper<T>: @unchecked Sendable {
        var value: T
        
        init(_ value: T) {
            self.value = value
        }
    }
    
    nonisolated let events: SendableWrapper<[Event]> = .init([])
    
    nonisolated let beginBackgroundTaskExpirationHandler: SendableWrapper<(() -> Void)?> = .init(nil)
    nonisolated let beginBackgroundTaskReturnValue: SendableWrapper<UIBackgroundTaskIdentifier> = .init(.invalid)
    
    nonisolated func setBeginBackgroundTaskReturnValue(_ value: UIBackgroundTaskIdentifier) {
        beginBackgroundTaskReturnValue.value = value
    }
    
    // MARK: - UIApplicationProtocol
    
    nonisolated func beginBackgroundTask(
        withName taskName: String?,
        expirationHandler handler: (@MainActor @Sendable () -> Void)?
    ) -> UIBackgroundTaskIdentifier {
        beginBackgroundTaskExpirationHandler.value = {
            DispatchQueue.main.async {
                handler?()
            }
        }
        
        events.value.append(.beginBackgroundTask(taskName))
        
        return beginBackgroundTaskReturnValue.value
    }
    
    nonisolated func endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier) {
        events.value.append(.endBackgroundTask(identifier))
    }
    
    nonisolated func canOpenURL(_ url: URL) -> Bool {
        false
    }
    
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any]) async -> Bool {
        false
    }
}
