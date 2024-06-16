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
    func notifications(named name: Notification.Name, object: AnyObject?) -> NotificationCenter.Notifications
    func publisher(for name: Notification.Name, object: AnyObject?) -> NotificationCenter.Publisher
}

extension NotificationCenterProtocol {
    func notifications(named name: Notification.Name, object: AnyObject? = nil) -> NotificationCenter.Notifications {
        notifications(named: name, object: object)
    }
}

extension NotificationCenter: NotificationCenterProtocol { }
