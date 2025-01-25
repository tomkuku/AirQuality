//
//  NotificationCenterProtocol.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 03/06/2024.
//

import Foundation

protocol HasNotificationCenter {
    var notificationCenter: NotificationCenterProtocol { get }
}

protocol NotificationCenterProtocol: Sendable {
    func post(name aName: NSNotification.Name, object anObject: Any?)
    
    func notifications(
        named name: Notification.Name,
        object: (any AnyObject & Sendable)?
    ) -> NotificationCenter.Notifications
    
    func publisher(for name: Notification.Name, object: AnyObject?) -> NotificationCenter.Publisher
}

extension NotificationCenterProtocol {
    func notifications(
        named name: Notification.Name,
        object: (AnyObject & Sendable)? = nil
    ) -> NotificationCenter.Notifications {
        notifications(named: name, object: nil)
    }
}

extension NotificationCenter: NotificationCenterProtocol { }
